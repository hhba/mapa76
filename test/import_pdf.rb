#encoding: utf-8
require "classifier"
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/text")
require File.join(File.expand_path(File.dirname(__FILE__)),"/../lib/docsplit")
require "test/unit"
 
class TestImportPdf < Test::Unit::TestCase
  def test_import
    text = Docsplit.extract_text_from_pdf_str(open("data/f.pdf").read)
    assert(text.length > 0)
    assert_equal("Poder Judicial de la Nación\nAño del Bicentenario\nExpte. n° 563/99\n",Docsplit.find_header(text))
    cleaned_text = Docsplit.clean_text(text)
    assert(cleaned_text.index(" fs. 32 y 72 y\nvta., Copello "), "Page number")
    assert_equal("///ta, 21 de diciembre de 2.010.
AUTOS Y VISTOS:
Para dictar sentencia en esta ca", cleaned_text[0..80])

  end
end
