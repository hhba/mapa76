require 'test_helper'

describe NamedEntitiesRecognitionTask do
  let(:output) {
    output = NamedEntitiesRecognitionTask.new({
      'data' => ['string'],
      'metadata' => {}
    }).call
  }

  before do
    analyzer = Object.new
    analyzer.expects(:tokens).returns({})
    AnalyzerClient.expects(:new).with('string').returns(analyzer)
  end

  it 'returns tokens' do
    output['data'].must_equal [[]]
  end
end
