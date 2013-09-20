require 'test_helper'

describe PeopleController do
  context "People's controller" do
    before do
      @user = create :user
      @person = create :person
      sign_in @user
    end

    it "Add a person to the blacklist" do
      post :blacklist, :id => @person.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal 1, Blacklist.count
    end
  end
end
