require "spec_helper"

describe Blacklist do
  before do
    @named_entity = create :named_entity
    @person = build :person
    @person.named_entities << @named_entity
    @person.save
  end

  it "should add a person and all it's named entities to a blacklist object" do
    blacklist = Blacklist.add(@person)

    assert_equal @person.full_name, blacklist.text
    assert_equal @person.named_entities, blacklist.named_entities
  end
end
