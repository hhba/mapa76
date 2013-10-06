require 'test_helper'

describe Api::V1::NamedEntitiesController do
  let(:document){ FactoryGirl.create :document }
  let(:named_entity) { FactoryGirl.create :where_entity }
  let(:user) { FactoryGirl.create :user }

  before do
    document.named_entities << named_entity
    sign_in user
  end

  describe '#show' do
    context 'correct params' do
      it '' do
        get :show, id: named_entity.id,
          document_id: document.id,
          format: 'json'
        response.status.must_equal 200
      end
    end

    context 'bad parameters' do
      it 'respond with 400' do
        get :show, id: "9", type: 'json'
        response.status.must_equal 400
      end
    end
  end
end
