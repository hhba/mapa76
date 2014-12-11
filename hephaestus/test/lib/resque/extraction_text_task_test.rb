require 'test_helper'

describe ExtractionTextTask do
  it 'extract text from URL' do
    input = {
      'data' => 'https://s3.amazonaws.com/src.codingnews.info/tapa.txt'
    }
    ExtractionTextTask.any_instance.stubs(:get_content).returns("El contenido")

    output = ExtractionTextTask.new(input).call
    output[:metadata][:size].must_equal 15
    output[:metadata][:current_task].must_equal 'extraction_text_task'
  end
end
