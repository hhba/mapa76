require "test_helper"

describe NotificationMailer do
  let(:user) { FactoryGirl.build :user }
  let(:document) { FactoryGirl.build :document }
  let(:invitation) { FactoryGirl.create :invitation }
  let(:contact) { FactoryGirl.create :contact }

  it 'sends flag email' do
    NotificationMailer.flag(user, document).deliver

    ActionMailer::Base.deliveries.wont_be_empty
  end

  it 'sends invitation request email' do
    NotificationMailer.invitation_request(invitation).deliver

    ActionMailer::Base.deliveries.wont_be_empty
  end

  it 'sends contact request email' do
    NotificationMailer.contact(contact).deliver

    ActionMailer::Base.deliveries.wont_be_empty
  end
end
