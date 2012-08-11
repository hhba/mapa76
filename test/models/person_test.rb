# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestPerson < Test::Unit::TestCase
  context "Person finders" do
    setup do
      @p1 = create :person, name: "Cocó Fuente"
      @p2 = create :person, name: "Coco Fontana"
      @p3 = create :person, name: "Capital Federal"
    end

    should "" do
      name = "Juan Péréz"
      name_t = "juan perez"
      p = create :person, name: name
      p.save

      #person = Person.find(name: name)
      person = Person.first(conditions: { name: name })
      assert_equal(p.id, person.id, "This should be the same person")

      person = Person.filter_by_name(name_t).first
      assert_equal(name, person.name, "Person.filter_by_name(#{name_t})")

      cocos = Person.filter_by_name("coc", true).all
      assert_equal(2, cocos.length)
    end
  end

  # def test_finders

  # end

  # def test_blacklist
  #   person = Person.create name: "Policia Federal"
  #   person.blacklist

  #   assert_raise Mongoid::Errors::DocumentNotFound do
  #     Person.find(person.id)
  #   end
  # end

  # def test_blacklisted
  #   [@p1, @p2, @p3].each(&:blacklist)

  #   assert_equal "name_1", Blacklist.first.text
  #   assert_equal 5, Blacklist.count
  # end
end