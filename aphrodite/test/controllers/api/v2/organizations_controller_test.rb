require 'test_helper'

describe Api::V2::OrganizationsController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }
  let(:organization) { FactoryGirl.create :organization }

  before do
    document.organizations << organization
    user.documents << document
    authenticate_api(user.access_token)
  end

  describe 'GET #index' do
    it 'retrieves documents' do
      get :index, format: 'json', document_id: document.id
      response.status.must_equal 200
      json.first['name'].must_equal organization.name
    end
  end
end
