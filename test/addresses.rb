#encoding:utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require "test/unit"
class TestAddresses < Test::Unit::TestCase
  def test_simple
    pt = Text.new " Su participación en el asalto de la casa de la calle Belén 335 no está en discusión"
    assert_equal("Belén 335",pt.addresses.first)
    pt = Text.new " asd Balcarce 1624, Lanus Oeste, blabla"
    assert_equal("Balcarce 1624, Lanus Oeste",pt.addresses.first)
    pt = Text.new " Scalabrini Ortiz 1234, "
    assert_equal("Scalabrini Ortiz 1234",pt.addresses.first)
    pt = Text.new " Av. Gral Paz 5005, "
    assert_equal("Av. Gral Paz 5005",pt.addresses.first)
  end
end

