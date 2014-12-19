require 'test_helper'

describe Invitation do
  describe 'validations' do
    it '' do
      invitation = Invitation.new
      invitation.valid?.must_equal false
      invitation.name = 'John'
      invitation.email = 'john@gmail.com'
      invitation.valid?.must_equal true
    end
  end

  describe '#generate_token' do
    it 'generates a token before creating' do
      invitation = FactoryGirl.build :invitation
      invitation.token.must_equal ''
      invitation.save
      invitation.token.wont_equal ''
    end
  end
end
