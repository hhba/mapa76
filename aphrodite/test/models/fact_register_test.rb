require 'test_helper'

describe FactRegister do
  context "FactRegister" do
    before do
      name_entity   = FactoryGirl.create :name_entity,   document: @document
      date_entity   = FactoryGirl.create :date_entity,   document: @document
      place_entity  = FactoryGirl.create :place_entity,  document: @document
      action_entity = FactoryGirl.create :action_entity, document: @document

      @register = FactoryGirl.create :fact_register, {
        document: @document,
        person_ids: [name_entity.id],
        action_ids: [action_entity.id],
        date_id: date_entity.id,
        place_id: place_entity.id,
        passive: false,
      }
    end

    it "generate timeline JSON" do
      assert_instance_of String, FactRegister.timeline_json
    end
  end
end
