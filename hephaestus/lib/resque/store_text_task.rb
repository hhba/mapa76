require 'json'


class StoreTextTask < BaseTask
  @queue = :store_text_task
  @msg = "Storing text"
  @next_task = nil

  attr_accessor :document, :text

  def initialize(input)
    @document_id = input['metadata']['document_id']
    @metadata = input['metadata']
    @text = input['data']
  end

  def call
    store_text
    @output = {
      'data' => @text,
      'metadata' => @metadata.merge({
        'pages' => document.pages.size
      })
    }
  end

  def store_text
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

  def document
    @document ||= Document.find(@document_id)
  end
end
