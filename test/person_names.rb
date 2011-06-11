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
  end
end

