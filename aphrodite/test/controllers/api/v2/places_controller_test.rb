require 'test_helper'

describe Api::V2::PlacesController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }
  let(:place) { FactoryGirl.create :place }
  let(:address) { FactoryGirl.create :address }

  before do
    document.places << place
    document.addresses << address

    user.documents << document
    authenticate_api(user.access_token)
  end

  describe 'GET #index' do
    it 'retrieves documents' do
      get :index, format: 'json', document_id: document.id
      response.status.must_equal 200
      names = json.map { |e| e['name'] }

      names.must_include place.name
      names.must_include address.name
    end
  end
end
