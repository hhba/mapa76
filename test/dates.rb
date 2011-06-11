#encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require "test/unit"
 
class TestDates < Test::Unit::TestCase
   
  def test_simple
    t=Text.new " 3 de diciembre del 77."  
    assert_equal(Date.civil(1977,12,3).to_s  ,  t.dates.first.to_s )
    
    t=Text.new "3 de diciembre del 1977."
    assert_equal(Date.civil(1977,12,3).to_s,  t.dates.first.to_s )
    
    t=Text.new "julio del 78"
    assert_equal(Date.civil(1978,7).to_s,     t.dates.first.to_s ) 

    t=Text.new "6 de diciembre"
    assert_equal(Date.civil(0,12,6).to_s,     t.dates.first.to_s )

    t=Text.new "diciembre de 1978"
    assert_equal(Date.civil(1978,12,1).to_s,  t.dates.first.to_s )

    t=Text.new "3/11"

    t=Text.new "27/11/77"
    assert_equal(Date.civil(1977,11,27).to_s, t.dates.first.to_s )

    t=Text.new "abril del ´78"
    assert_equal(Date.civil(1978,4,1).to_s,     t.dates.first.to_s )

    t=Text.new "fines de noviembre 1977"
    assert_equal(Date.civil(1977,11,1).to_s,  t.dates.first.to_s )

    t=Text.new "juicio del 25 de junio de 2008. "
    assert_equal(Date.civil(2008,6,25).to_s,  t.dates.first.to_s )
    
  end
end
