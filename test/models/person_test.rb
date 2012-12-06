# encoding: utf-8
require "test_helper"

class TestPerson < Test::Unit::TestCase
  context "Populate people" do
    setup do
      patty1  = create :named_entity, text: "Luis Abelardo Patty"
      patty2  = create :named_entity, text: "Luis Ableardo Patty"
      videla1 = create :named_entity, text: "Jorge Rafael Videla"

      @document = create :document
      @duplicates = [[patty1, patty2], [videla1]]
    end

    should "Add one person per group of duplicates" do
      Person.populate @document, @duplicates

      assert_equal 2, Person.count
      assert_equal 2, Person.first.named_entities.count
    end
    
    should "not create a new person if it's already stored" do
      create :person, name: "Eduardo Massera", tags: ['procesados', 'condenados', 'condenados']
      named_entity = create :named_entity, text: "Eduardo Massera"
      duplicates = [[named_entity]]

      Person.populate @document, duplicates
      assert_equal 1, Person.count
      assert_equal named_entity, Person.first.named_entities.first
    end

    should "search for all the posibilities when verifying it's not already in the database"
    # Maybe it can use the method Add
  end
end
