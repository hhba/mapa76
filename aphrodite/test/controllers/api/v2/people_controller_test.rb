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
    it 'returns a list of persons' do
      get :index, format: 'json', document_id: document.id
      response.status.must_equal 200
      json.first['name'].must_equal person.name
    end
  end
end
