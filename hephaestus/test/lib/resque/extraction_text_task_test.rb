require 'stringio'
require 'test_helper'

# has output
# calls next task

describe ExtractionTextTask do
  it 'behaves like a task' do
    [:@queue, :@msg, :@next_task].each do |instance_variable|
      ExtractionTextTask.instance_variable_get(instance_variable).wont_be_nil
    end
    ExtractionTextTask.instance_variable_get(:@next_task).must_equal('store_text_task')
  end

  it 'responds to call' do
    task = ExtractionTextTask.new({'data' => {}, 'metadata' => {}})
    task.must_respond_to :call
  end

  it 'has an output with data and metadata' do
    input = {
      'data' => {
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
      'data' => {
        'document_id' => document.id.to_s
      }
    }

    output = ExtractionTextTask.new(input).call
    output['metadata']['size'].must_equal 15
    output['metadata']['current_task'].must_equal 'extraction_text_task'
    output['metadata']['document_id'].must_equal document.id.to_s
  end
end
