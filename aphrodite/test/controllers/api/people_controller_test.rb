require 'test_helper'

describe PeopleController do
  context "People meta info" do
    before do
      @person = create :person
    end

    it "Should list document's name" do
      get :show, :id => @person.id
      status = JSON.parse(@response.body)

      assert_response :success
    end
  end
end
