# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestAnalyzer < Test::Unit::TestCase
  def setup
    @short = "Alegato fiscal. Causa “Campo de Mayo III”. Diciembre 2010."

    @text = "Luis Abelardo Patti, es argentino, nacido el día 26 de noviembre " \
      "de 1952 en Baigorrita, Provincia de Buenos Aires, policía " \
      "retirado, titular del DNI n° 10.635.503, domiciliado en Belgrano " \
      "n° 349 de Escobar, Provincia de Buenos Aires y actualmente en " \
      "prisión preventiva."
  end

  def test_extract_tokens
    tokens = Analyzer.extract_tokens("")
    assert_equal [], tokens.to_a

    tokens = Analyzer.extract_tokens(@short)
    assert_equal [
      {:form=>"Alegato", :pos=>0},
      {:form=>"fiscal", :pos=>8},
      {:form=>".", :pos=>14},
      {:form=>"Causa", :pos=>16},
      {:form=>"“", :pos=>22},
      {:form=>"Campo", :pos=>23},
      {:form=>"de", :pos=>29},
      {:form=>"Mayo", :pos=>32},
      {:form=>"III", :pos=>37},
      {:form=>"”", :pos=>40},
      {:form=>".", :pos=>41},
      {:form=>"Diciembre", :pos=>43},
      {:form=>"2010", :pos=>53},
      {:form=>".", :pos=>57}
    ], tokens.to_a
  end

  def test_extract_named_entities
    named_entities = Analyzer.extract_named_entities(@text)

    person = named_entities.find{|ne| ne[:form] == "Luis_Abelardo_Patti"}
    assert person
    assert_equal NamedEntity::CLASSES_PER_TAG.invert[:people], person[:tag]
    assert_equal 0, person[:pos]
    assert_equal [
        {:pos=>0, :form=>"Luis"},
        {:pos=>5, :form=>"Abelardo"},
        {:pos=>14, :form=>"Patti"}
      ], person[:tokens]

    date = named_entities.find{|ne| ne[:form] == "día_26_de_noviembre_de_1952"}
    assert date
    assert_equal NamedEntity::CLASSES_PER_TAG.invert[:date], date[:tag]
    assert_equal 45, date[:pos]
    assert_equal "[??:26/11/1952:??.??:??]", date[:lemma]
  end
end
