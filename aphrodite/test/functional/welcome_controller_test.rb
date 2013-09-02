require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  context "WelcomeController" do
    setup do
      @document = create :document, public: true
    end

    should "Respond 200" do
      get :index
      assert_response 200
      assert_select ".documents li a", @document.title
    end
  end
end
