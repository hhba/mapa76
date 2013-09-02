# encoding: utf-8
require "test_helper"

class TestAnalyzer < Test::Unit::TestCase
  def setup
    @short = "Alegato fiscal. Causa “Campo de Mayo III”. Diciembre 2010."

    @text = "Luis Abelardo Patti, es argentino, nacido el día 26 de noviembre " \
      "de 1952 en Baigorrita, Provincia de Buenos Aires, policía " \
      "retirado, titular del DNI n° 10.635.503, domiciliado en Belgrano " \
      "n° 349 de Escobar, Provincia de Buenos Aires y actualmente en " \
      "prisión preventiva."

    @two_sentences = "Reynaldo Benito Antonio Bignone, es argentino, nacido el " \
      "día 21 de enero de 1928 en el Partido de Morón, Provincia de Buenos " \
      "Aires, casado, militar retirado, Libreta de Enrolamiento n° 4.779.986, " \
      "con domicilio real en la calle Dorrego n° 2699, piso 6°, departamento " \
      "2°, de la Ciudad Autónoma de Buenos Aires, actualmente con  prisión " \
      "preventiva. Juan Fernando Meneghini, es argentino, nacido el día 28 de " \
      "enero de 1936 en San Pedro, Provincia de Buenos Aires, instruido, " \
      "Comisario reiterado, con domicilio real en Mariani n° 7868 de Mar del " \
      "Plata, Partido de General Pueyrredón, Provincia de Buenos Aires y " \
      "actualmente con prisión domiciliaria."
  end

  def test_extract_tokens_empty_string
    tokens = Analyzer.extract_tokens("")
    assert_equal [], tokens.to_a
  end

  def test_extract_tokens_short_text
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
    ].map(&:stringify_keys), tokens.to_a
  end

  def test_extract_named_entities
    named_entities = Analyzer.extract_named_entities(@text)

    person = named_entities.find { |ne| ne.form == "Luis_Abelardo_Patti" }
    assert person
    assert_equal NamedEntity::CLASSES_PER_TAG.invert[:people], person.tag
    assert_equal 0, person.pos
    assert_equal 0, person.sentence_pos
    assert_equal [
        {:pos=>0,  :form=>"Luis"},
        {:pos=>5,  :form=>"Abelardo"},
        {:pos=>14, :form=>"Patti"}
      ].map(&:stringify_keys), person.tokens

    date = named_entities.find { |ne| ne.form == "día_26_de_noviembre_de_1952" }
    assert date
    assert_equal NamedEntity::CLASSES_PER_TAG.invert[:dates], date.tag
    assert_equal 45, date.pos
    assert_equal 0, date.sentence_pos
    assert_equal "[??:26/11/1952:??.??:??]", date.lemma
  end

  def test_extract_named_entities_multiple_sentences
    named_entities = Analyzer.extract_named_entities(@two_sentences)

    person_a = named_entities.find{|ne| ne.form == "Reynaldo_Benito_Antonio_Bignone"}
    assert person_a
    assert_equal NamedEntity::CLASSES_PER_TAG.invert[:people], person_a.tag
    assert_equal 0, person_a.sentence_pos

    person_b = named_entities.find{|ne| ne.form == "Juan_Fernando_Meneghini"}
    assert person_b
    assert_equal NamedEntity::CLASSES_PER_TAG.invert[:people], person_b.tag
    assert_equal 1, person_b.sentence_pos
  end

  def test_extract_addresses
    named_entities = Analyzer.extract_named_entities("Scalabrini Ortiz 1234, Sanchez de Bustamante al 2000.").to_a

    address_a = named_entities.find { |ne| ne.tag == NamedEntity::CLASSES_PER_TAG.invert[:addresses] }
    assert address_a
  end
end
