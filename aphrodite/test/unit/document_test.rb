require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  context "Document" do
    setup do
      @document = create :document
      @document.update_attributes :percentage => 100, :category => 'Veredicto'
    end

    should "Generate context" do
      name_entity = create :name_entity, document: @document
      date_entity = create :date_entity, document: @document
      action_entity = create :action_entity, document: @document

      register = create :fact_register, {
        document: @document,
        person_ids: [name_entity.id],
        action_ids: [action_entity.id],
        date_id: date_entity.id
      }

      person = create :person
      @document.people << person

      assert_equal register.people.first.text, @document.context[:registers].first[:who].first
      assert_equal @document.title, @document.context[:title]
      assert_equal person.name, @document.context[:people].first[:name]
    end

    should "generate CSV with all the people"
    should "Export registers as CSV"
  end
end
