require "test_helper"

class TestBlacklist < Test::Unit::TestCase
  context "Blacklist" do
    setup do
      @named_entity = create :named_entity
      @person = build :person
      @person.named_entities << @named_entity
      @person.save
    end

    should "add a person and all it's named entities to a blacklist object" do
      blacklist = Blacklist.add(@person)

      assert_equal @person.full_name, blacklist.text
      assert_equal @person.named_entities, blacklist.named_entities
    end
  end
end
