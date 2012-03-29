#encoding: utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/incomplete_date")
require "test/unit"
 
class TestIncompleteDate < Test::Unit::TestCase
   
  def test_simple
    tests = [
      ["month only",[1981,12,nil],"1981-12"],
      ["year only",[1981,nil,nil],"1981"],
    ]
    tests.each{|msg,date,str|
      assert_equal(IncompleteDate.new(*date).to_s, str, msg )
    }
  end
  def test_parse
    tests = [
      ["month only","1981-12-00","1981-12"],
      ["month only","1981-12","1981-12"],
      ["year only","1981","1981"],
    ]
    tests.each{|msg,date,str|
      assert_equal(IncompleteDate.new_from_str(date).to_s, str, msg )
    }
  end
  def test_comparisions
    jan = IncompleteDate.new(2000,1,nil)
    dec = IncompleteDate.new(2000,12,nil)
    millenium = IncompleteDate.new(2000,nil,nil)
    assert(jan < dec, "Expected #{jan} < #{dec}")
    assert(millenium > jan, "Expected #{millenium} > #{jan}")

    first_jan = IncompleteDate.new(2000,1,1)
    assert_equal(first_jan,Date.new(2000,1,1),"Full date in IncompleteDate compared to Date")

    first_nov = Date.new(2000,11,1)
    assert(dec > first_nov,"Date < IncompleteDate")

    complete_first_jan = Date.new(2000,1,1)
    assert_equal(first_jan, complete_first_jan)
  end
end
