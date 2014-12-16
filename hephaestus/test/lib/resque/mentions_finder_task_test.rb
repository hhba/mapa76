require 'test_helper'

describe MentionsFinderTask do
  let(:user)     { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }
  let(:named_entity) { FactoryGirl.create :organization_entity, text: 'org1', lemma: 'org1', form: 'org1' }
  let(:address_entity) { FactoryGirl.create :address_entity }
  let(:organization) { FactoryGirl.create(:organization, name: 'org1', mentions: {"1" => 1})}
  let(:input) { { 'metadata' => {'document_id' => document.id.to_s }} }

  before do
    user.documents << document
    document.named_entities << named_entity
    document.named_entities << address_entity
  end

  context 'There is NO other organization with the same name' do
    it 'creates a new organization' do
      MentionsFinderTask.new(input).call
      organization = Organization.last
      organization.name.must_equal named_entity.text
      organization.mentions[document.id.to_s].must_equal 1
      document.reload
      document.organizations.length.must_equal 1
    end
  end

  context 'There is already an organization with the same name' do
    it 'adds the mentions for the current document' do
      user.organizations << organization
      MentionsFinderTask.new(input).call
      organization = Organization.last
      organization.name.must_equal named_entity.form
      organization.mentions.length.must_equal 2
      document.reload
      document.organizations.length.must_equal 1
    end
  end

  context 'There is no address with the same name' do
    it 'creates an address' do
      MentionsFinderTask.new(input).call
      address = Address.last
      address.name.must_equal address_entity.text
      address.mentions[document.id.to_s].must_equal 1
      document.reload
      document.addresses.length.must_equal 1
    end
  end
end
