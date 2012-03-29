#encoding: utf-8
require 'test/unit'
require 'text'
require 'incomplete_date'

class TestDates < Test::Unit::TestCase
  def test_simple
    t = Text.new(" 3 de diciembre del 77.")
    assert_equal(IncompleteDate.new(1977, 12, 3), t.dates.first)

    t = Text.new("3 de diciembre del 1977.")
    assert_equal(IncompleteDate.new(1977, 12, 3), t.dates.first)

    t = Text.new("julio del 78")
    assert_equal(IncompleteDate.new(1978, 7), t.dates.first)

    t = Text.new("6 de diciembre")
    assert_equal(IncompleteDate.new(0, 12, 6), t.dates.first)

    t = Text.new("diciembre de 1978")
    assert_equal(IncompleteDate.new(1978, 12), t.dates.first)

    t = Text.new("27/11/77")
    assert_equal(IncompleteDate.new(1977, 11, 27), t.dates.first)

    t = Text.new("abril del ´78")
    assert_equal(IncompleteDate.new(1978, 4), t.dates.first)

    t = Text.new("fines de noviembre 1977")
    assert_equal(IncompleteDate.new(1977, 11), t.dates.first)
    assert_equal("1977-11-0", t.dates.first.to_s(0), "fill unknowns with 0")

    assert_equal(IncompleteDate.parse("1977-11-0"), IncompleteDate.new(1977, 11))
    assert_equal(IncompleteDate.parse("1977-01-00"), IncompleteDate.new(1977, 1))
    assert_equal(IncompleteDate.parse("1977"), IncompleteDate.new(1977))

    t = Text.new("juicio del 25 de junio de 2008. ")
    assert_equal(IncompleteDate.new(2008, 6, 25), t.dates.first)

    t = Text.new("1° de junio de 1978")
    assert_equal(IncompleteDate.new(1978, 6, 1), t.dates.first)

    t = Text.new("18/19 de julio de 1977")
    assert_equal(IncompleteDate.new(1977, 7), t.dates.first)

    t = Text.new(" 1º de diciembre de 1977 ")
    assert_equal(IncompleteDate.new(1977, 12, 1), t.dates.first)

    t = Text.new(" 1-1-1977 ")
    assert_equal(IncompleteDate.new(1977, 1, 1), t.dates.first)

    t = Text.new("l 26/04/79. Alli se ratifica j")
    assert_equal(IncompleteDate.new(1979, 4, 26), t.dates.first)

    t = Text.new("mayoria")
    assert_equal(nil, t.dates.first)

    t = Text.new("mes de noviembre hasta")
    assert_equal(nil, t.dates.first)
  end
end
