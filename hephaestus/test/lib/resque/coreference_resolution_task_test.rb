# encoding: utf-8
require "test_helper"

describe CoreferenceResolutionTask do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }
  let(:person) { FactoryGirl.create :person, name: "Ernesto" }
  let(:cor) do
    CoreferenceResolutionTask.new({
      'data' => '',
      'metadata' => {
        'document_id' => document.id.to_s
      }
    })
  end

  describe '#call' do
    it '' do
      user.documents << document
      document.named_entities << FactoryGirl.create(:person_entity)
      cor.call
      document.reload
      document.people.length.must_equal 1
      document.people.first.mentions[document.id.to_s].wont_be_nil
    end
  end

  describe '#find_duplicates' do
    before do
      ne1_attr = {
        text:     "Ernesto Guevara",
        form:     "Ernesto_Guevara",
        lemma:    "ernesto_guevara"
      }
      ne2_attr = {
        text:     "Ernesto Geuvara",
        form:     "Ernesto_Geuvara",
        lemma:    "ernesto_geuvara"
      }
      ne3_attr = ne1_attr
      ne4_attr = {
        text:     "Marcos",
        form:     "Marcos",
        lemma:    "marcos"
      }
      ne5_attr = {
        text:     "Marcso",
        form:     "Marcso",
        lemma:    "marcso"
      }
      ne6_attr = {
        text:     "Rene",
        form:     "Rene",
        lemma:    "rene"
      }
      @ne1 = FactoryGirl.create :person_entity, ne1_attr
      @ne2 = FactoryGirl.create :person_entity, ne2_attr
      @ne3 = FactoryGirl.create :person_entity, ne3_attr
      @ne4 = FactoryGirl.create :person_entity, ne4_attr
      @ne5 = FactoryGirl.create :person_entity, ne5_attr
      @ne6 = FactoryGirl.create :person_entity, ne6_attr
      @named_entities = [@ne1, @ne2, @ne3, @ne4, @ne5, @ne6]
    end

    it 'group dup entities' do
      dup = cor.find_duplicates(@named_entities)
      dup.length.must_equal 3
      dup.first.must_include(@ne1)
      dup.first.must_include(@ne2)
      dup.first.must_include(@ne3)
      dup[1].must_include(@ne4)
      dup[1].must_include(@ne5)
      dup[2].must_include(@ne6)

      dup.flatten.length.must_equal 6
    end
  end

  describe '#jarowinkler_distance' do
    it 'returns true' do
      cor.jarowinkler_distance("Ernesto", "Ernesot").must_equal true
    end

    it 'returns false' do
      cor.jarowinkler_distance("Ernesto", "Albert").must_equal false
    end
  end

  describe '#branting_distance' do
    it 'returns true' do
      cor.branting_distance("Ernesto Guevara", "Ernesot Guevara").must_equal true
    end

    it 'returns false' do
      cor.branting_distance("Ernesto Guevara", "Albert Einstein").must_equal false
    end
  end

  describe '#store' do
    before do
      user.people << person
      document.user = user
      document.save
      @ne1 = FactoryGirl.create :person_entity, {
        text:     "Ernesto",
        form:     "Ernesto",
        lemma:    "ernesto"
      }
      @ne2 = FactoryGirl.create :person_entity
      document.named_entities << @ne1
      document.named_entities << @ne2
    end

    it 'Adds a mention to the existing person' do
      document.people << person
      cor.store(@ne1) # => Ernesto
      document.reload
      document.people.length.must_equal 1
      document.people.first.mentions.must_equal({document.id.to_s => 1})
    end

    it 'Creates a new person' do
      cor.store(@ne2)
      document.reload
      document.people.length.must_equal 1
      document.people.first.name.must_equal @ne2.text
      document.people.first.mentions.must_equal({document.id.to_s => 1})
    end
  end
end
