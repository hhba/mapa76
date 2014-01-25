require 'test_helper'

describe EntitiesExtractionTask do
  let(:document){ FactoryGirl.create :document, processed_text: '' }
  let(:page) {FactoryGirl.create :page, from_pos: 0, to_pos: 100}
  let(:entities_extractor) { EntitiesExtractionTask.new(document.id) }
  let(:token) do stub(form: "form", lemma: "lemma", tag: "NP00SP0",
                      prob: 1.0, text: 'text', pos: 0)
  end

  before do
    document.pages << page
  end

  describe '#call' do
    it '' do
      address_extractor = stub(call: [])
      analyzer_client = stub(tokens: [token])
      AnalyzerClient.stubs(:new).returns(analyzer_client)
      AddressExtractor.stubs(:new).returns(address_extractor)
      entities_extractor.call
      document.reload
      document.named_entities.length.must_equal 1
    end
  end

  describe '#store' do
    it '' do
      entities_extractor.store(token)
      page.reload
      document.reload
      page.named_entities.length.must_equal 1
      document.named_entities.length.must_equal 1
    end
  end

  describe '#find_page' do
    it '' do
      entities_extractor.find_page(10).must_equal page
    end
  end
end
