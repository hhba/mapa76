require "docsplit"

class NormalizationTask
  extend ProcessingStrategy

  @queue = :normalization

  PDF2HTML_BIN = ENV['PDF2HTML_BIN'] || "/usr/local/bin/pdftohtml"

  ##
  # Split original document data and extract metadata and content as
  # clean, plain text for further analysis.
  #
  # When finished, enqueue the layout analysis task to optimize the document
  # for NERC analysis.
  #
  def self.perform(document_id)
    doc = Document.find(document_id)
    doc.update_attribute :state, :normalizing

    logger.info "Ensure document is a PDF (convert if necessary)"
    pdf_path = Docsplit.ensure_pdfs(doc.original_file_path).first

    raise "Something failed when converting document to a PDF file" if pdf_path.nil?

    # Replace title with original title from document
    logger.info "Extract title from '#{pdf_path}'"
    doc.title = Docsplit.extract_title(pdf_path)

    logger.info "Generate a thumbnail from the first page of the document"
    doc.thumbnail_file = self.create_thumbnail(pdf_path, {
      :output => File.join(Padrino.root, 'public', THUMBNAILS_DIR)
    })

    logger.info "Extract PDF as an XML document"
    xml = self.pdf_to_xml(pdf_path)

    logger.info "Clean old pages (if any)"
    doc.pages.delete_all
    doc.fontspecs = {}

    logger.info "Iterate through every page and text line, normalize and store them"
    xml.css("page").each_with_index do |xml_page, page_index|
      logger.info "Page #{page_index + 1}"

      logger.debug "Create and normalize text lines for page #{page_index + 1}"
      text_lines = xml_page.css("text").map.with_index do |tl, tl_index|
        text_line = TextLine.new({
          :text => tl.inner_html,
          :processed_text => self.normalize(tl.inner_html),
          :left => tl.attributes["left"].value.to_i,
          :top  => tl.attributes["top"].value.to_i,
          :width  => tl.attributes["width"].value.to_i,
          :fontspec_id => tl.attributes["font"].value,
        })
        text_line.id = tl_index + 1
        text_line
      end
      logger.debug "#{text_lines.size} text lines were processed"

      logger.debug "Get fontspecs for page #{page_index + 1}"
      xml_page.css("fontspec").each do |fs|
        id = fs.attributes["id"].value
        doc.fontspecs[id] = {
          :family => fs.attributes["family"].value,
          :size   => fs.attributes["size"].value.to_i,
          :color  => fs.attributes["color"].value,
        }
      end

      logger.debug "Create page #{page_index + 1} and store text lines and attributes"
      doc.pages << Page.new({
        :num => page_index + 1,
        :width => xml_page.attributes["width"].value.to_i,
        :height => xml_page.attributes["height"].value.to_i,
        :text_lines => text_lines,
      })
    end
    logger.info "#{doc.pages.count} pages were processed"

    logger.info "Save document"
    doc.save

    logger.info "Enqueue Layout Analysis task"
    Resque.enqueue(LayoutAnalysisTask, document_id)
  end

private
  ##
  # Export the first page of a document as a PNG file as a thumbnail of a
  # document.
  #
  def self.create_thumbnail(path, opts={})
    opts = {
      :size => '65x80'
    }.merge(opts)

    basename = File.basename(path).split('.')[0..-2].join('.')
    filename = basename + '.png'

    Docsplit.extract_images(path, opts.merge(:pages => 1))

    return "#{basename}_1.png"
  end

  ##
  # Normalize string for analyzer
  #   * Strip whitespace
  #   * Remove HTML tags (like <b></b>)
  #
  def self.normalize(string)
    string
      .strip
      .gsub(/<\/?[^>]*>/, '')
  end

  ##
  # Extracts XML from a PDF using Poppler's `pdftohtml`
  #
  def self.pdf_to_xml(path, opts={})
    params = ["-stdout", "-xml", "-enc UTF-8", "-wbt 20"]
    params << "-f #{opts[:from]}" if opts[:from]
    params << "-l #{opts[:to]}" if opts[:to]
    logger.debug "pdf2html options: #{params}"

    command = "#{PDF2HTML_BIN} #{params.join(" ")} '#{path.gsub("'", "\\'")}'"
    logger.debug "Run #{command}"
    content = `#{command}`

    logger.debug "Parse XML output"
    require "nokogiri"
    xml = Nokogiri::XML(content)
  end
end
