require "spec_helper"

describe FactRegister do
  before do
    name_entity   = create :name_entity,   document: @document
    date_entity   = create :date_entity,   document: @document
    where_entity  = create :where_entity,  document: @document
    action_entity = create :action_entity, document: @document

    @register = create :fact_register, {
      document: @document,
      person_ids: [name_entity.id],
      action_ids: [action_entity.id],
      date_id: date_entity.id,
      place_id: where_entity.id,
      passive: false,
    }
  end

  it "should generate json" do
    assert_instance_of String, FactRegister.timeline_json
  end
end
