# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestDocument < Test::Unit::TestCase
  def setup
    #Document.dataset.truncate
    Document.delete_all
    #DocumentsPerson.dataset.truncate # no se usa mas este modelo
    @person = Person.create(name: "Josecito")
  end

  def test_new_doc
    d = Document.new
    d.title = "TestingDoc123"
    d.content = "áAca viene Juan Perez maxt"
    d.save
    assert_equal("Juan Perez", d.extract.person_names.first.to_s)
    assert_equal("áAca viene", d.fragment(0, 10))
  end

  def test_new_doc_person
    d = Document.new
    d.title = "TestingDoc123"
    d.content = "Oxopato maxt"
    d.save
    d.people << @person

    #assert_equal(33, @person.mentions_in(d))
    assert_equal(1, d.people.length)
    assert_equal([@person], d.people)
  end

end
