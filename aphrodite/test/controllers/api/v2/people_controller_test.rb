require 'test_helper'

describe Api::V2::PeopleController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }
  let(:person) { FactoryGirl.create :person }

  before do
    document.people << person
    user.documents << document
    authenticate_api(user.access_token)
  end

  describe 'GET #index' do
    context 'For a single document' do
      it 'returns a list of persons' do
        get :index, format: 'json', document_id: document.id
        response.status.must_equal 200
        json.first['name'].must_equal person.name
      end
    end

    context 'For multiple documents' do
      it 'returns people for many documents' do
        request.env['HTTP_X_DOCUMENT_IDS'] = document.id.to_s
        get :index, format: 'json'
        json.first['name'].must_equal person.name
      end
    end
  end

  describe 'GET #show' do
    it 'returns a person info' do
      get :show, format: 'json', id: person.id
      response.status.must_equal 200
      json['name'].must_equal person.name
    end
  end
end
