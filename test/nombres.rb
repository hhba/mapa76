#encoding:utf-8
require "./lib/procesar_texto"
require "test/unit"
class TestNombres < Test::Unit::TestCase
  def test_simple
    d = []
    d << "Tambien dijo que Colores y Turco Julian, a quienes vio a cara descubierta, le hicieron presenciar la tortura de su prima"
    pt=ProcesarTexto.new(d)
    n=pt.nombres_propios
    assert_equal("Turco Julian",n[0])
  end
end

