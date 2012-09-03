# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestRegister < Test::Unit::TestCase
  context "Register" do
    setup do
      name_entity  = create :name_entity,  document: @document
      date_entity  = create :date_entity,  document: @document
      where_entity = create :where_entity, document: @document
      @register    = create :register, document: @document, who: [name_entity.id], what: "nacio", when: [date_entity.id], where: [where_entity.id]
    end

    should "Generate json" do
      assert_instance_of String, Register.timeline_json
    end
  end
end
