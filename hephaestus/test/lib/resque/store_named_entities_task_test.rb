require 'test_helper'

describe StoreNamedEntitiesTask do
  it 'store named entities' do
    page = FactoryGirl.create(:page, from_pos: 0, to_pos: 100)
    document = FactoryGirl.create(:document)
    document.pages << page
    input = {
      'data' => [{"form" => "ocupar","lemma" => "ocupar","tag" => "VMN0000","prob" => 1.0,"pos" => 1}],
      'metadata' => {
        'document_id' => document.id.to_s
      }
    }
    NamedEntity.expects(:valid_token?).returns(true)

    StoreNamedEntitiesTask.new(input).call

    document.reload
    document.named_entities.wont_be_empty
  end
end
