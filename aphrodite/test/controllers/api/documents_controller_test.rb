require 'test_helper'

describe DocumentsController do
  context "Documents list and show" do
    before do
      @document = FactoryGirl.create :document, percentage: 100
    end

    it "Should list document's name" do
      get :show, :id => @document.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal @document.title, status['title']
    end
  end
end
