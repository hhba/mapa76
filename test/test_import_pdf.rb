# encoding: utf-8
require 'test/unit'
require 'test_helpers'
require 'ext/docsplit'
require 'text'

class TestImportPdf < Test::Unit::TestCase
  def test_import
    text = Docsplit.extract_text_from_pdf_str(open(data_path("f.pdf")).read)
    assert(text.length > 0)
    assert_equal("Poder Judicial de la Nación\nAño del Bicentenario\nExpte. n° 563/99\n", Docsplit.find_header(text))
    cleaned_text = Docsplit.clean_text(text)
    assert(cleaned_text.index(" fs. 32 y 72 y\nvta., Copello "), "Page number")
    assert_equal("///ta, 21 de diciembre de 2.010.
AUTOS Y VISTOS:
Para dictar sentencia en esta ca", cleaned_text[0..80])
  end

  def test_import2
    text = Docsplit.extract_text_from_pdf_str(open(data_path("2.pdf")).read)
    assert(text.length > 0)
    assert_equal("Poder Judicial de la Nación\nAño del Bicentenario\n", Docsplit.find_header(text))
    cleaned_text = Docsplit.clean_text(text)
    open("/tmp/w","w") { |fd| fd.write(cleaned_text) }
    assert_equal("\n///Plata, noviembre\n\nde 2010.-\n\nY VISTOS:\nEn el día de la fecha se reúnen los in", cleaned_text[0..80])
    assert(cleaned_text.index("a cargo de los\nseñores Fiscales"), "Page number")
  end
end
