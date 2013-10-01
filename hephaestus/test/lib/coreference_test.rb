# encoding: utf-8
require "test_helper"

class TestCoreference < Test::Unit::TestCase
  context "Coreference!" do
    setup do
      @patty1  = create :named_entity, text: "Luis Abelardo Patty"
      @patty2  = create :named_entity, text: "Luis Ableardo Patty"
      @patty3  = create :named_entity, text: "Luis Patty"
      @videla1 = create :named_entity, text: "Jorge Rafael Videla"
      @pomulo1 = create :named_entity, text: "Peperino Pomulo"
      @patty4  = create :named_entity, text: "Luis Ableardo Patty"
      @wrong   = create :named_entity, text: "policia federal"
      @one     = create :named_entity, text: "policia"

      @named_entities = [@patty2, @patty3, @videla1, @pomulo1, @patty4]
    end

    should "test_find_duplicates" do
      processed = [
        [@patty3, @patty4, @patty2], [@videla1], [@pomulo1]
      ]
      result = Coreference.find_duplicates(@named_entities)
      assert_equal processed, result, "Duplication"
    end

    should "test_resolve" do
      document = create :document, id: 1
      assert_equal 3, Coreference.resolve(document, @named_entities).count
    end

    should "test_remove_blacklisted" do
      named_entities = [@patty2, @patty3, @videla1, @pomulo1, @patty4, @wrong]
      result = [@patty2, @patty3, @videla1, @pomulo1, @patty4]
      Person.create(name: "policia federal").blacklist

      assert_equal result, Coreference.remove_blacklisted(named_entities)
    end

    should "find named entities with one word" do
      named_entities = [@patty1, @patty2, @one]
      assert_equal [@patty1, @patty2], Coreference.remove_one_word(named_entities)
    end

    should "find one word named entities" do
      named_entities = [@patty1, @patty2, @one]
      assert_equal [@one], Coreference.find_one_words(named_entities)
    end
  end
end
