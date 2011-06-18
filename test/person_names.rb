#encoding:utf-8
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require "test/unit"
class TestPersonNames < Test::Unit::TestCase
  def test_simple
    d = []
    d << "Tambien dijo que Colores y Turco Julian, a quienes vio a cara descubierta, le hicieron presenciar la tortura de su prima"
    pt=Text.new(d)
    n=pt.person_names
    assert_equal("Turco Julian",n[0])
    pt=Text.new("onectaron con empresarios del nivel de Roberto Rocca, Enrique Piñeiroi, Franco Macri, toda gente conocida de su padre que habia ")
    n=pt.person_names
    assert_equal("Roberto Rocca", n[0])
    assert_equal("Enrique Piñeiroi", n[1])
    assert_equal("Franco Macri", n[2])

  end
end

