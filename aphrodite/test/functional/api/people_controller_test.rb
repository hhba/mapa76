require 'test_helper'

class Api::PeopleControllerTest < ActionController::TestCase
  context "People meta info" do
    setup do
      @person = create :person
    end

    should "Should list document's name" do
      get :show, :id => @person.id
      status = JSON.parse(@response.body)

      assert_response :success
    end
  end
end
