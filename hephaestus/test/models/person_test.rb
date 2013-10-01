# encoding: utf-8
require "test_helper"

describe Person do
  describe '#update_mentions' do
    let(:document) { FactoryGirl.create :document }
    let(:person) { FactoryGirl.create :person }

    it 'has no mentions' do
      person.documents << document

      person.mentions.must_equal({})
    end

    it 'update counters' do
      person.documents << document
      named_entity = FactoryGirl.create :named_entity, document: document
      person.named_entities << named_entity
      person.save

      person.mentions.must_equal({document.id => 1})
    end
  end

  context "Populate people" do
    before do
      patty1  = FactoryGirl.create :named_entity, text: "Luis Abelardo Patty"
      patty2  = FactoryGirl.create :named_entity, text: "Luis Ableardo Patty"
      videla1 = FactoryGirl.create :named_entity, text: "Jorge Rafael Videla"

      @document = FactoryGirl.create :document
      @duplicates = [[patty1, patty2], [videla1]]
    end

    it "Add one person per group of duplicates" do
      Person.populate @document, @duplicates

      assert_equal 2, Person.count
      assert_equal 2, Person.first.named_entities.count
    end

    it "not create a new person if it's already stored" do
      FactoryGirl.create :person, name: "Eduardo Massera", tags: ['procesados', 'condenados', 'condenados']
      named_entity = create :named_entity, text: "Eduardo Massera"
      duplicates = [[named_entity]]

      Person.populate @document, duplicates
      assert_equal 1, Person.count
      assert_equal named_entity, Person.first.named_entities.first
    end

    it "search for all the posibilities when verifying it's not already in the database"
    # Maybe it can use the method Add
  end
end
