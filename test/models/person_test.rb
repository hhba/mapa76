# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestPerson < Test::Unit::TestCase
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
