# encoding: utf-8
require "test_helper"

# TODO Migrate these tests to another test for coverage of border cases and
# precision of addresses detection.

class TestAddresses < Test::Unit::TestCase
=begin
  def test_simple
    pt = Text.new(" Su participación en el asalto de la casa de la calle Belén 335 no está en discusión")
    assert_equal("Belén 335", pt.addresses.first)

    pt = Text.new(" asd Balcarce 1624, Lanus Oeste, blabla")
    assert_equal("Balcarce 1624, Lanus Oeste", pt.addresses.first)

    pt = Text.new(" Scalabrini Ortiz 1234, ")
    assert_equal("Scalabrini Ortiz 1234", pt.addresses.first)

    pt = Text.new(" Av. Gral Paz 5005, ")
    assert_equal("Av. Gral Paz 5005", pt.addresses.first)

    pt = Text.new(" Olimpo ")
    assert_equal("Olimpo", pt.addresses(["Olimpo"]).first)

    pt = Text.new("Sanchez de Bustamante al 2000")
    assert_equal("Sanchez de Bustamante al 2000", pt.addresses.first)

    pt = Text.new(" Juan B Alberdi 5045")
    assert_equal("Juan B Alberdi 5045", pt.addresses.first)

    assert false
  end
=end
end
