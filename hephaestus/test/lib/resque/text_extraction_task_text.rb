require 'test_helper'

describe TextExtractionTask do
  it "extracts text in to multiple pages" do
    text = "Mi nombre es Marcos.\fVoy a viajar a Paris."
    document = FactoryGirl.create :document

    text_extraction_task = TextExtractionTask.new(document.id)
    text_extraction_task.store(text)

    document.reload
    document.pages.count.must_equal 2
    document.processed_text.must_equal "Mi nombre es Marcos.Voy a viajar a Paris."
    document.pages.last.from_pos.must_equal 20
  end
end