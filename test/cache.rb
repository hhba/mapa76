#encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require "test/unit"
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

    str = StringDocument.new("Rulo Gomez Castaña y yo")
    str.id = 33
    doc = Text.new(str)
    names = doc.person_names
    pedro = names[0]
    roque = names[1]
    assert_equal( "frag:doc=33:0-19", pedro.id ) 
    assert_equal( "Rulo Gomez Castaña",pedro.context(0))

  end
end
