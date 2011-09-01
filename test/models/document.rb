#!/usr/bin/env ruby
#encoding: utf-8
PADRINO_ENV = "test"
require File.expand_path(File.dirname(__FILE__)) + "/../../config/boot.rb"

require "test/unit"

class TestDocument < Test::Unit::TestCase
  def setup
    Document.dataset.truncate
    DocumentsPerson.dataset.truncate
    @person = Person.create(name: "Josecito")
  end
  def test_new_doc
    d = Document.new
    d.title = "TestingDoc123"
    d.data = "áAca viene Juan Perez maxt"
    d.save
    assert_equal("Juan Perez",d.extract.person_names.first.to_s)
    assert_equal("áAca viene",d.fragment(0,10))
  end
  def test_new_doc_person
    d = Document.new
    d.title = "TestingDoc123"
    d.data = "Oxopato maxt"
    d.save
    d.add_person(@person,33)

    assert_equal(33,@person.mentions_in(d))
    assert_equal(1,d.person.length)
    assert_equal([@person],d.person)
  end

end
