require 'test_helper'

describe User do
  context 'with a token' do
    it 'validations pass without token' do
      user = FactoryGirl.build :user
      user.invitation_token = 'bad token'
      user.valid?.must_equal false
    end

    it 'validation pass with correct invitation token' do
      invitation = FactoryGirl.create :invitation
      user = FactoryGirl.build :user
      user.invitation_token = invitation.token
      user.valid?.must_equal true
    end
  end

  context 'without a token' do
    it 'validations pass without token' do
      user = FactoryGirl.build :user
      user.valid?.must_equal true
    end
  end
end
