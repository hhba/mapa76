require "test_helper"

describe FlagMailer do
  let(:user) { FactoryGirl.build :user }
  let(:document) { FactoryGirl.build :document }

  it 'sends flag email' do
    email = FlagMailer.flag(user, document).deliver

    ActionMailer::Base.deliveries.wont_be_empty
  end
end

