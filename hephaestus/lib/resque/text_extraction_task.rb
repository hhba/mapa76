require 'tempfile'
require 'tmpdir'

class TextExtractionTask < Base
  @queue = :text_extraction_task
  @msg = "Extrayendo texto"
  attr_reader :document

  def self.perform(document_id)
    self.new(document_id).call
  end

  def initialize(id)
    @document = Document.find(id)
    @document.update_attribute :processed_text, ''
    @document.pages.delete_all
  end

  def call
    text = ''

    Tempfile.open(document.original_filename) do |temp|
      document.file.each do |chunk|
        temp.write(chunk)
      end
      temp.close
      Dir.mktmpdir do |temp_dir|
        Docsplit.extract_text(temp.path, output: temp_dir)
        text = File.open(File.join(temp_dir, build_txt(document.original_filename))).read
        text = text.force_encoding('UTF-8')
      end
    end
    store(text)
  end

  def build_txt(filename)
    filename.split(".")[0..-2].join(".") + '.txt'
  end

  def store(text)
    pos = 0
    text.split("\f").each_with_index do |text_page, index|
      text_page = text_page.gsub("  ", " ")
      page = Page.create({
        num:      index + 1,
        text:     text_page,
        from_pos: pos,
        to_pos:   pos + text_page.length,
      })
      document.pages << page
      pos = pos + text_page.length
    end
    pages = Page.where(document_id: document.id).asc(:num)
    document.processed_text = pages.map { |p| p.text }.join#(' ')
    document.save!
  end
end
