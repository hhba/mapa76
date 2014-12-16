require 'stringio'
require 'test_helper'

# has output
# calls next task

describe ExtractionTextTask do
  it 'responds to call' do
    task = ExtractionTextTask.new({'data' => {}, 'metadata' => {}})
    task.must_respond_to :call
  end

  it 'has an output with data and metadata' do
    input = {
      'metadata' => {
        'url' => 'https://s3.amazonaws.com/src.codingnews.info/tapa.txt'
      }
    }
    ExtractionTextTask.any_instance.stubs(:get_content).returns("El contenido")

    output = ExtractionTextTask.new(input).call
    output['data'].wont_be_nil
    output['metadata'].wont_be_nil
    output['metadata']['size'].must_equal 15
  end

  it 'extracts text from a document (txt)' do
    document = FactoryGirl.create :document, file: StringIO.new("El contenido")
    input = {
      'metadata' => {
        'document_id' => document.id.to_s
      }
    }

    output = ExtractionTextTask.new(input).call
    output['metadata']['size'].must_equal 15
    output['metadata']['current_task'].must_equal 'extraction_text_task'
    output['metadata']['document_id'].must_equal document.id.to_s
  end
end
