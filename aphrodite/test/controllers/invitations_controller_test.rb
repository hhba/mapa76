require "test_helper"

describe InvitationsController do
  context 'singed in' do
    before do
      user = FactoryGirl.create :user
      sign_in user
    end

    it 'redirects to documents_path' do
      get :new
      response.status.must_equal 302
    end
  end

  context 'signed out' do
    describe '#new' do
      it 'works ok' do
        get :new
        response.status.must_equal 200
      end
    end

    describe '#create' do
      it 'creates an invitation request' do
        mailer = mock(deliver: true)
        NotificationMailer.expects(:invitation_request).returns(mailer)

        post :create, invitation: FactoryGirl.attributes_for(:invitation)
        response.status.must_equal 302
      end
    end
  end
end
