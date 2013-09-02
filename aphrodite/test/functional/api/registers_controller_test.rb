require 'test_helper'

class Api::RegistersControllerTest < ActionController::TestCase
  context "Create or not create new registers" do
=begin
    should "Return a hash when creating" do
      def Register.create(opts)
        true
      end
      post :create, :something => true
      
      assert_response 201
    end

    should "Return nothing when not creating" do
      def Register.create(opts)
        false
      end
      post :create, :something => true
      
      assert_response 405
    end
=end
  end
end
