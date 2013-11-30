require 'test_helper'

describe EntitiesProvider do
  let(:user) { FactoryGirl.create :user }
  let(:document1) { FactoryGirl.create :document }
  let(:document2) { FactoryGirl.create :document }
  let(:organization1) { FactoryGirl.create :organization }
  let(:organization2) { FactoryGirl.create :organization }
  let(:person1) { FactoryGirl.create :person }

  before do
    document1.organizations << organization1
    document2.organizations << organization2
    document2.people << person1

    user.documents << document1
    user.documents << document2
  end

  it 'provides organizations for a list of documents' do
    provider = EntitiesProvider.new(user, :organizations)
    organizations = provider.for([document1.id, document2.id])

    organizations.must_include(organization1)
    organizations.must_include(organization2)
  end

  it 'provides people for a document' do
    provider = EntitiesProvider.new(user, :people)
    provider.for([document2]).must_include(person1)
  end
end
