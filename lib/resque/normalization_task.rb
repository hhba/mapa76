require "docsplit"
require "nokogiri"

class NormalizationTask
  @queue = :normalization

  PDF2HTML_BIN = ENV['PDF2HTML_BIN'] || "pdftohtml"

  ##
  # Split original document data and extract metadata and content as
  # clean, plain text for further analysis.
  #
  # When finished, enqueue the extraction task to detect and classify named
  # entities.
  #
  def self.perform(document_id)
    doc = Document.find(document_id)
    doc.update_attribute :state, :normalizing

    # Replace title with original title from document
    logger.info "Extract title from '#{doc.original_file_path}'"
    doc.title = Docsplit.extract_title(doc.original_file_path)

    logger.info "Generate a thumbnail from the first page of the document"
    doc.thumbnail_file = self.create_thumbnail(doc.original_file_path, {
      :output => File.join(Padrino.root, 'public', THUMBNAILS_DIR)
    })

    logger.info "Extract PDF as an XML document"
    xml = self.pdf_to_xml(doc.original_file_path)

    doc.fontspecs = {}

    xml.css("page").each_with_index do |xml_page, page_index|
      text_lines = xml_page.css("text").map.with_index do |tl, tl_index|
        TextLine.new({
          :num  => tl_index + 1,
          :text => tl.text,
          :left => tl.attributes["left"].value.to_i,
          :top  => tl.attributes["top"].value.to_i,
          :fontspec_id => tl.attributes["font"].value,
        })
      end

      xml_page.css("fontspec").each do |fs|
        id = fs.attributes["id"].value
        doc.fontspecs[id] = {
          :family => fs.attributes["family"].value,
          :size   => fs.attributes["size"].value.to_i,
          :color  => fs.attributes["color"].value,
        }
      end

      doc.pages << Page.new({
        :num => page_index + 1,
        :width => xml_page.attributes["width"].value.to_i,
        :height => xml_page.attributes["height"].value.to_i,
        :text_lines => text_lines,
      })
    end

    logger.info "Save document"
    doc.save

    logger.info "Enqueue Extraction task"
    Resque.enqueue(ExtractionTask, document_id)
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
  # Extracts XML from a PDF using Poppler's `pdftohtml`
  #
  def self.pdf_to_xml(path, opts={})
    params = ["-stdout", "-xml", "-enc UTF-8"]
    params << "-f #{opts[:from]}" if opts[:from]
    params << "-l #{opts[:to]}" if opts[:to]
    logger.debug "pdf2html options: #{params}"

    command = "#{PDF2HTML_BIN} #{params.join(" ")} '#{path.gsub("'", "\\'")}'"
    logger.debug "Run #{command}"
    content = `#{command}`

    logger.debug "Parse XML output"
    xml = Nokogiri::XML(content)
  end

end
