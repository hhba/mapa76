require 'test_helper'

class Api::DocumentsControllerTest < ActionController::TestCase
  context "Documents list and show" do
    setup do
      @document = FactoryGirl.create :document
    end

    should "Should list document's name" do
      get :show, :id => @document.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal @document.title, status['title']
    end

    should "destroy a document" do
      initial_count = Document.count
      delete :destroy, id: @document.id
      final_count = Document.count

      assert_equal initial_count - 1, final_count
    end
  end
end
