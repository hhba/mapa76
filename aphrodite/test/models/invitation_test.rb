require 'test_helper'

describe Invitation do
  context 'class methods' do
    describe '#burn!' do
      context 'invitation not burned' do
        it 'returns true' do
          invitation = FactoryGirl.create :invitation
          Invitation.burn!(invitation.token).must_equal true
        end
      end

      context 'invitation already burned' do
        it 'returns false' do
          invitation = FactoryGirl.create :invitation, burned_at: Time.now
          Invitation.burn!(invitation.token).must_equal false
        end
      end

      context 'invitation not exist' do
        it 'returns false' do
          Invitation.burn!('notoken').must_equal false
        end
      end
    end
  end

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

  describe '#burn!' do
    it '' do
      invitation = FactoryGirl.create :invitation
      invitation.burned_at.must_equal nil
      invitation.burn!
      invitation.burned_at.must_be_instance_of DateTime
    end
  end

  describe '#burned?' do
    context 'already burned' do
      it '' do
        invitation = FactoryGirl.create :invitation,  burned_at: Time.now
        invitation.burned?.must_equal true
      end
    end

    context 'not burned' do
      it '' do
        invitation = FactoryGirl.create :invitation
        invitation.burned?.must_equal false
      end
    end
  end
end
