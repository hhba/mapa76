# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

# TODO Migrate these tests to another test for coverage of border cases and
# precision of named entities detection.

class TestPersonNames < Test::Unit::TestCase
=begin
  def test_simple
    d = []
    d << "Tambien dijo que Colores y Turco Julian, a quienes vio a cara descubierta, le hicieron presenciar la tortura de su prima"
    pt = Text.new(d)
    n = pt.person_names
    assert_equal("Turco Julian", n[0])

    pt = Text.new("onectaron con empresarios del nivel de Roberto Rocca, Enrique Piñeiroi, Franco Macri, toda gente conocida de su padre que habia ")
    n = pt.person_names
    assert_equal("Roberto Rocca", n[0])
    assert_equal("Enrique Piñeiroi", n[1])
    assert_equal("Franco Macri", n[2])

    pt = Text.new("Jose Gonçalves")
    n = pt.person_names
    assert_equal("Jose Gonçalves", n[0])

    t = "ctualmente detenido en el  JUAN CARLOS AVENA, de nacionalidad argentina "
    pt = Text.new(t)
    n = pt.person_names
    assert_equal(["JUAN CARLOS AVENA"], n)

    t = ". En tanto que Leon permaneció en cautiverio también en el Banco desde donde fue trasladado a su destino final. LEON GAJNAJ PERMANECE DESPARECIDO."
    pt = Text.new(t)
    n = pt.person_names
    assert_equal(["LEON GAJNAJ"], n)
  end
=end
end
