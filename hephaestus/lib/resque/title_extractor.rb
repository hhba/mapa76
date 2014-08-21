require 'open-uri'
require 'nokogiri'


class TitleExtractor < Base
  def initialize(document_id)
    @document = Document.find(document_id)
  end

  def call
    @document.title = extract_title
    @document.save
  end

  def extract_title
    doc = Nokogiri::HTML(open(@document.url))
    doc.css('title').text
  end
end
