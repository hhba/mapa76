require 'test_helper'

describe Api::V2::DocumentsController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }

  context 'Authorized' do
    before do
      user.documents << document
      authenticate_api(user.access_token)
    end

    describe 'GET #index' do
      it 'returns a list of documents' do
        get :index, format: 'json'
        response.status.must_equal 200
        json.first['title'].must_equal document.title
      end
    end
  end

  context 'Unauthorized' do
    describe 'GET #index' do
      it 'returns 401' do
        get :index, format: 'json'
        response.status.must_equal 401
      end
    end
  end
end
