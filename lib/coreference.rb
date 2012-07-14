# encoding: utf-8
require 'amatch'

module Coreference
  MIN_SIMILARITY = 0.85

  def self.find_duplicates(named_entities)
    duplicates = []
    while !named_entities.empty?
      named_entity = named_entities.shift

      jw = Amatch::JaroWinkler.new(named_entity.text)
      group = named_entities.select do |ne|
        jw.match(ne.text) >= MIN_SIMILARITY
      end
      logger.debug "Duplicates of '#{named_entity.text}': #{group.map(&:text)}"

      named_entities.reject! { |ne| group.include?(ne) }
      duplicates << group
    end
    duplicates
  end

  def self.resolve(document, named_entities)
    duplicates = find_duplicates(named_entities.to_a)
    Person.populate(document, duplicates)
  end
end

