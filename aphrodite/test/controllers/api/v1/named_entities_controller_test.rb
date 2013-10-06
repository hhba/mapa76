require 'test_helper'

describe Api::V1::NamedEntitiesController do
  let(:document){ FactoryGirl.create :document }
  let(:user) { FactoryGirl.create :user }

  before do
    sign_in user
  end

  describe '#show' do
    it '' do
      get :show, id: 1, format: 'json'
      response.status.must_equal 200
    end
  end
end
