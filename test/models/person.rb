#!/usr/bin/env ruby
#encoding: utf-8
PADRINO_ENV = "test"
require File.expand_path(File.dirname(__FILE__)) + "/../../config/boot.rb"

require "test/unit"

class TestPerson < Test::Unit::TestCase
  def setup
    Person.dataset.truncate
    @p1=Person.create(name: "Cocó Fuente")
    @p2=Person.create(name: "Coco Fontana")
  end
  def test_finders
    name = "Juan Péréz"
    name_t = "juan perez"
    p = Person.new 
    p.name = name
    p.save

    person = Person.find(name: name)
    assert_equal(p.id,person.id,"This should be the same person")

    person = Person.filter_by_name(name_t).first
    assert_equal(name,person.name,"Person.filter_by_name(#{name_t})")

    cocos = Person.filter_by_name("coc",true).all
    assert_equal(2,cocos.length)
  end
end
