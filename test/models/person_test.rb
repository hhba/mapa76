# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

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

  context "Add new person" do
    setup do
      @p1 = create :person, name: "Luciano Benjamín MenÉndez", tags: ['procesados']
      @p2 = create :person, name: "Eduardo Massera", tags: ['procesados', 'condenados', 'condenados']
    end

    should "Not add an existing person" do
      Person.add "Luciano Benjamín MenÉndez", tag: 'condenados'

      assert_equal 2, Person.first.tags.length
    end

    should "have unique tags" do
      assert_equal 2, @p2.tags.length
    end
  end

  context "Person finders" do
    setup do
      @p1 = create :person, name: "Cocó Fuente"
      @p2 = create :person, name: "Coco Fontana"
      @p3 = create :person, name: "Capital Federal"
    end

    should "do something that makes silvanis happy" do
      name = "Juan Péréz"
      name_t = "juan perez"
      p = create :person, name: name

      person = Person.first(conditions: { name: name })
      assert_equal(p.id, person.id, "This should be the same person")

      person = Person.filter_by_name(name_t).first
      assert_equal(name, person.name, "Person.filter_by_name(#{name_t})")

      cocos = Person.filter_by_name("coc", true).all
      assert_equal(2, cocos.length)
    end
  end

  context 'Blacklist' do
    setup do
      @person = create :person, name: "Policia Federal"
      @person.blacklist
    end

    should "not find the user once it was marked as blacklist" do
      assert_raise Mongoid::Errors::DocumentNotFound do
        Person.find(@person.id)
      end
    end
  end
end
