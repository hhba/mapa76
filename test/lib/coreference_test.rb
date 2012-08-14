# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestCoreference < Test::Unit::TestCase
  context "This is ugly" do
    setup do
      @patty1  = create :named_entity, text: "Luis Abelardo Patty"
      @patty2  = create :named_entity, text: "Luis Ableardo Patty"
      @patty3  = create :named_entity, text: "Luis Patty"
      @videla1 = create :named_entity, text: "Jorge Rafael Videla"
      @pomulo1 = create :named_entity, text: "Peperino Pomulo"
      @patty4  = create :named_entity, text: "Luis Ableardo Patty"
      @wrong   = create :named_entity, text: "Policia Federal"
      
      @named_entities = [@patty2, @patty3, @videla1, @pomulo1, @patty4]
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
      @named_entities = [@patty2, @patty3, @videla1, @pomulo1, @patty4, @wrong]
      result = [@patty2, @patty3, @videla1, @pomulo1, @patty4] 
      Person.create(name: "Policia Federal").blacklist

      assert_equal result, Coreference.remove_blacklisted(@named_entities)
    end
  end
end
