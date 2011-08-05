#encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require "test/unit"
module Cacheable
  def cache_load(foo)
    :notcached
  end
end
class TestFragments < Test::Unit::TestCase
  def test_fragment_id
    str = StringDocument.new("aa Pedro Gomez ááá Róqúé Péréz #{"a " * 500} Don Nadie")
    str.id = 33
    doc = Text.new(str)
    names = doc.person_names
    pedro = names[0]
    roque = names[1]
    assert_equal( "frag:doc=33:3-14", pedro.id ) 
    assert_equal( "Pedro Gomez",pedro.context(0))
    assert_equal( "frag:doc=33:22-38", roque.id ) 
    assert_equal( "Róqúé Péréz", roque.context(0))

    pedro_context = pedro.context.extract
    pedro_context_names = pedro_context.person_names

    assert_equal( 2 , pedro_context_names.length ) 
    
    roque_from_pedro_context = pedro_context_names[1]
    assert_equal( "frag:doc=33:22-38", roque_from_pedro_context.id ) 

  end


  def test_fragment_of_fragment
    str = StringDocument.new(<<EOS
ó reñidas con los valores democráticos. \r\n        * Martín Rodríguez
EOS
)
    str.id = 33
    doc = Text.new(str)
    person_names = doc.person_names
    puts person_names
    assert_equal(1,person_names.length,"There's only one name in text")
    assert_equal("Martín Rodríguez", person_names.first.context(0))
    first_frag_id = person_names.first.fragment_id

    martin_in_own_context = person_names.first.context.extract.person_names.first
    assert_equal(first_frag_id, martin_in_own_context.fragment_id,"Wrong fragment id of the first name in its own context")
    assert_equal("Martín Rodríguez", martin_in_own_context.context(0),"name.context(0) should be equal to name")


  end
end
