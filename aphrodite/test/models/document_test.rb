require 'test_helper'

describe Document do
  describe '#flag!' do
    it 'flags a document' do
      user = mock(id: Moped::BSON::ObjectId.new)
      document = FactoryGirl.create :document

      document.flag!(user)
      document.flagger_id.must_be_instance_of Moped::BSON::ObjectId
    end
  end

  describe "#flagged?" do
    it '' do
      document = FactoryGirl.create :document, flagger_id: Moped::BSON::ObjectId.new
      document.flagged?.must_equal true
    end
  end

  before do
    @document = FactoryGirl.create :document
    @document.update_attributes :percentage => 100, :category => 'Veredicto'
  end

  it "Generate context" do
    name_entity = FactoryGirl.create :name_entity, document: @document
    date_entity = FactoryGirl.create :date_entity, document: @document
    action_entity = FactoryGirl.create :action_entity, document: @document

    register = FactoryGirl.create :fact_register, {
      document: @document,
      person_ids: [name_entity.id],
      action_ids: [action_entity.id],
      date_id: date_entity.id
    }

    person = FactoryGirl.create :person
    @document.people << person

    assert_equal @document.title, @document.context[:title]
    assert_equal person.name, @document.context[:people].first[:name]
  end

  describe "validate number of documents" do
    it "does not allow you to create more than 50 documents" do
      user = FactoryGirl.create :user
      50.times { FactoryGirl.create(:document, user: user) }

      doc = Document.new
      doc.user = user

      doc.valid?.must_equal false
      puts doc.errors.messages
      doc.errors.messages[:documents_count].wont_be_nil
    end
  end
end
