#encoding:utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require "test/unit"
class TestAddresses < Test::Unit::TestCase
  def test_simple
    d = []
    d << " Su participación en el asalto de la casa de la calle Belén 335 no está en discusión"
    d << " asd Balcarce 1624, Lanus Oeste, blabla"
    pt=Text.new(d)
    dir=pt.addresses.map{|d|
      Text::Address.new_from_string_with_context(d)
    }
    assert_equal("Belén 335",dir[0])
    assert_equal("Balcarce 1624, Lanus Oeste",dir[1])
  end
end

