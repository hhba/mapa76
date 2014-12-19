require 'test_helper'

describe User do
  context 'without a token' do
    it 'validations pass without token' do
      user = FactoryGirl.build :user
      user.valid?.must_equal true
    end
  end

  describe '#access_token' do
    it 'has an access_token as default' do
      user = FactoryGirl.create :user
      user.access_token.wont_be_nil
    end
  end
end
