require 'stringio'
require 'test_helper'


describe ExtractionTextTask do
  it 'extracts text from URL' do
    input = {
      'data' => {
        'url' => 'https://s3.amazonaws.com/src.codingnews.info/tapa.txt'
      }
    }
    ExtractionTextTask.any_instance.stubs(:get_content).returns("El contenido")

    output = ExtractionTextTask.new(input).call
    output['metadata']['size'].must_equal 15
    output['metadata']['current_task'].must_equal 'extraction_text_task'
  end

  it 'extracts text from a document (txt)' do
    document = FactoryGirl.create :document, file: StringIO.new("El contenido")
    input = {
      'data' => {
        'document_id' => document.id.to_s
      }
    }

    output = ExtractionTextTask.new(input).call
    output['metadata']['size'].must_equal 15
    output['metadata']['current_task'].must_equal 'extraction_text_task'
  end
end
