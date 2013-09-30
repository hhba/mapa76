require 'test_helper'

describe CsvGenerator do
  describe '#people' do
    let(:document) { FactoryGirl.create :document }

    before do
      named_entity_1 = FactoryGirl.create :named_entity
      named_entity_2 = FactoryGirl.create :named_entity

      person = FactoryGirl.create :person
      person.named_entities << named_entity_1
      person.named_entities << named_entity_2
    end

    it 'generates a persons csv row' do
    end
  end
end
