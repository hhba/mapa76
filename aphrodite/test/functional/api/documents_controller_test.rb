require 'test_helper'

class Api::DocumentsControllerTest < ActionController::TestCase
  context "Documents list and show" do
    setup do
      @document = FactoryGirl.create :document, percentage: 100
    end

    should "Should list document's name" do
      get :show, :id => @document.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal @document.title, status['title']
    end
  end
end
