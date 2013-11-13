require 'test_helper'

describe WelcomeController do
  context "WelcomeController" do
    before do
      @document = create :document, public: true
    end

    it "Respond 200" do
      get :index
      assert_response 200
    end
  end

  describe "Visit all pages" do
    it 'contact' do
      get :contact
      assert_response 200
    end

    it 'terms' do
      get :terms
      assert_response 200
    end

    it 'about' do
      get :about
      assert_response 200
    end

    it 'faq' do
      get :faq
      assert_response 200
    end
  end
end
