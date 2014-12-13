require 'test_helper'

describe StoreTextTask do
  let(:document) { FactoryGirl.create :document }
  let(:output) do
    StoreTextTask.new({
        'data' => "string.\fstring",
        'metadata' => {
          'document_id' => document.id.to_s
        }
    }).call
  end

  it 'stores text into an existing document' do
    output

    document.reload
    document.pages.count.must_equal 2
    document.processed_text.must_equal "string.string"
    document.pages.last.from_pos.must_equal 7
  end

  it 'returns valid output' do
    output['data'].must_equal "string.\fstring"
    output['metadata']['pages'].must_equal 2
  end
end
