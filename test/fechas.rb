require "./lib/procesar_texto"
require "test/unit"
 
class TestFechas < Test::Unit::TestCase
   
  def test_simple
    d = []
    d << " 3 de diciembre del 77."  
    d << "3 de diciembre del 1977."
    d << "julio del 78"
    d << "6 de diciembre"
    d << "diciembre de 1978"
    d << "3/11"
    d << "27/11/77"
    t=ProcesarTexto.new(d)
    f=t.fechas
    assert_equal(Date.civil(1977,12,3),  f[0] )
    assert_equal(Date.civil(1977,12,3),  f[1] )
    assert_equal(Date.civil(1978,7),     f[2] ) 
    assert_equal(Date.civil(0,12,6),     f[3] )
    assert_equal(Date.civil(1978,12,1),  f[4] )
    assert_equal(Date.civil(1977,11,27),  f[5] )
  end
end
