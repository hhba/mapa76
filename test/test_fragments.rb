#encoding: utf-8
require 'test/unit'
require 'text'

class TestFragments < Test::Unit::TestCase
  def setup
    ENV["SKIP_CACHE"] = "true"
  end

  def test_fragment_id
    str = StringDocument.new("aa Pedro Gomez ááá Róqúé Péréz #{"a " * 500} Don Nadie")
    str.id = 33
    doc = Text.new(str)
    names = doc.person_names
    assert_equal(3, names.length, "There're 3 names in orig str [Pedro Gomez, Roque Perez, Don Nadie] instead, got #{names.inspect}")
    pedro = names[0]
    roque = names[1]
    assert_equal("frag:doc=33:3-14", pedro.id)
    assert_equal("Pedro Gomez",pedro.context(0))
    assert_equal("frag:doc=33:19-30", roque.id)
    assert_equal("Róqúé Péréz", roque.context(0))

    pedro_context = pedro.context(30).extract
    pedro_context_names = pedro_context.person_names

    assert_equal(2, pedro_context_names.length, "Expected '[Pedro Gomez, XX]'  got #{pedro_context_names.inspect}")

    roque_from_pedro_context = pedro_context_names[1]
    assert_equal("frag:doc=33:19-30", roque_from_pedro_context.id)
  end

  def test_fragment_of_fragment
    str = StringDocument.new("0¹² Martín Rodríguez
 Pedro Gomez"
)
    str.id = 33
    doc = Text.new(str)
    person_names = doc.person_names
    assert_equal(2, person_names.length, "There're only 2 names in text [Martín Rodríguez, Pedro Gomez] got #{person_names.inspect}")
    assert_equal("Martín Rodríguez", person_names.first.context(0))
    first_frag_id = person_names.first.fragment_id

    persons_in_martin_context = person_names.first.context(0).extract.person_names
    assert_equal(1, persons_in_martin_context.length, "There's only one name in the fragment")
    martin_in_own_context = persons_in_martin_context.first
    assert_equal(person_names.first.to_s, martin_in_own_context.to_s, "Wrong fragment id of the first name in its own context")

    assert_equal(first_frag_id, martin_in_own_context.fragment_id, "Wrong fragment id of the first name in its own context")
    assert_equal("Martín Rodríguez", martin_in_own_context.context(0), "name.context(0) should be equal to name")
  end

  def test_fragment_of_fragment2
    str = StringDocument.new(<<E
Doce meses de juicio probaron la participación de los acusados en crímenes masivos cometidos contra un grupo humano del país definido por los perpetradores como enemigo a destruir en órdenes secretas de exterminio dictadas por la superioridad del ejército argentino. Oscar Rolon, Samuel Miara,  policía, alias “Cobani”, Oscar Augusto Rolon, policía, alias “Soler”,  Julio Hector Simon, policía, alias “Turco Julián”, Enrique José del Pino, militar, alias “Miguel”, Ricardo Taddei, policía, alias “Padre” o “Cura”, Raúl González, policía, alias “Negro Raúl”, Juan Carlos Avena, penitenciario, alias “Centeno”, Eugenio Jorge Uballes, policía, alias “Anteojito Quiroga” o “Führer”, Eduardo Emilio Kalinec, policía, alias “Dr. K”, Roberto Antonio Rosa, policía, alias “Clavel”, Juan Carlos Falcón, policía, alias “Kung Fu”, Luis Juan Donocik, policía, alias “Polaco chico”, Eugenio Pereyra Apestegui, gendarme, alias “Quintana”, Raúl Antonio Guglielminetti, militar, alias “Mayor Guastavino”, Guillermo Víctor Cardozo, gendarme, alias “Cortez”, Carlos Alberto Roque Tepedino, militar y Mario Alberto Gómez Arenad, son los nombres de los acusados que alimentaron entre 1977 y 1979 el campo de concentración que funcionó en las sedes de “Club Atlético”, “Banco” y “Olimpo” con personas identificadas como blancos a las que secuestraban y torturaban.
Se demostró que los acusados participaron en el cautiverio  y  en la entrega de prisioneros para su ejecución en el mar. En el juicio tampoco  faltó la prueba de la privación de libertad y tortura a niños y adolescentes, de embarazadas, ni la de apropiación de niños. Por ello los acusados deberán responder a esta acusación por considerárselos coautores de delito de lesa humanidad previsto en los incisos a), b), c) y e) del art. II de la Convención para la Prevención y Sanción del Delito de Genocidio de 1948, cuya validez para el derecho argentino fue repetidamente ratificada desde 1956 hasta 1994.
E
)
    doc = Text.new(str)
    person_names = doc.person_names
  end
end
