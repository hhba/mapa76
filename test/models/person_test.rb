# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestPerson < Test::Unit::TestCase
  def setup
    #Person.dataset.truncate
    Person.delete_all
    @p1 = Person.create(name: "Cocó Fuente")
    @p2 = Person.create(name: "Coco Fontana")
    @p3 = Person.create(name: "Capital Federal")
  end

  def test_finders
    name = "Juan Péréz"
    name_t = "juan perez"
    p = Person.new
    p.name = name
    p.save

    #person = Person.find(name: name)
    person = Person.first(conditions: { name: name })
    assert_equal(p.id, person.id, "This should be the same person")

    person = Person.filter_by_name(name_t).first
    assert_equal(name, person.name, "Person.filter_by_name(#{name_t})")

    cocos = Person.filter_by_name("coc", true).all
    assert_equal(2, cocos.length)
  end

  def test_blacklist
    person = Person.create name: "Policia Federal"
    person.blacklist

    assert_raise Mongoid::Errors::DocumentNotFound do
      Person.find(person.id)
    end
  end

  def test_blacklisted
    [@p1, @p2, @p3].each(&:blacklist)

    assert_equal "Cocó Fuente", Person.blacklisted.first
    assert_equal 3, Person.blacklisted.count
  end
end