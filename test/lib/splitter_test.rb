# encoding: utf-8
require "test_helper"

class TestSplitter < Test::Unit::TestCase
  def setup
    @file_a = data_path('f.pdf')
    @file_b = data_path('2.pdf')
  end

  def test_extract_plain_text
    text = Splitter.extract_plain_text(@file_a)
    assert(text.length > 0)
    assert(text.index(" fs. 32 y 72 y\nvta., Copello "), "Page number")
    assert_equal("///ta, 21 de diciembre de 2.010.\nAUTOS Y VISTOS:\nPara dictar sentencia en esta ca", text[0..80])

    text = Splitter.extract_plain_text(@file_b)
    assert(text.length > 0)
    assert(text.index("a cargo de los\nseñores Fiscales"), "Page number")
    assert_equal("\n///Plata, noviembre\n\nde 2010.-\n\nY VISTOS:\nEn el día de la fecha se reúnen los in", text[0..80])
  end
end
