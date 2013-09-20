require 'test_helper'

describe WelcomeController do
  context "WelcomeController" do
    before do
      @document = create :document, public: true
    end

    it "Respond 200" do
      get :index
      assert_response 200
      assert_select ".documents li a", @document.title
    end
  end
end
