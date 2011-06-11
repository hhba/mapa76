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
end
