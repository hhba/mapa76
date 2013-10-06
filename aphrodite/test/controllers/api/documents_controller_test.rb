require 'test_helper'

describe Api::DocumentsController do
  context "Documents list and show" do
    let(:document) { FactoryGirl.create :document }
    let(:user) { FactoryGirl.create :user }

    before do
      user.documents << document
      sign_in user
    end

    it "Should list document's name" do
      get :show, :id => document.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal document.title, status['title']
    end
  end
end
