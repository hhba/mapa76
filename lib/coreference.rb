# encoding: utf-8
require 'amatch'

module Coreference
  MIN_SIMILARITY = 0.8

  def self.find_duplicates(named_entities)
    duplicates = []
    message = ""
    while !named_entities.empty?
      named_entity = named_entities.pop

      jw = Amatch::JaroWinkler.new(named_entity.text)
      tmp = named_entities.select do |ne|
        jw.match(ne.text) >= MIN_SIMILARITY
      end

      named_entities.reject! { |ne| tmp.include?(ne)}
      duplicates << tmp
    end
    duplicates
  end

  def self.resolve(document, named_entities)
    named_entities = named_entities.to_a
    Person.populate(document, find_duplicates(named_entities))
  end
end

