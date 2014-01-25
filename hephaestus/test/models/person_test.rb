# encoding: utf-8
require "test_helper"

describe Person do
  describe '#update_mentions' do
    let(:document) { FactoryGirl.create :document }
    let(:person) { FactoryGirl.create :person }

    it 'has no mentions' do
      person.documents << document

      person.mentions.must_equal({})
    end
  end
end
