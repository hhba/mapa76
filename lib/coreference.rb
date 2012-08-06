# encoding: utf-8
require 'amatch'

module Coreference
  extend self

  MIN_SIMILARITY = 0.85

  def find_duplicates(named_entities, method=:branting)
    distance_method = "#{method}_distance".to_sym

    duplicates = []
    while !named_entities.empty?
      named_entity = named_entities.shift

      group = named_entities.select do |ne|
        send(distance_method, named_entity.text, ne.text) >= MIN_SIMILARITY
      end
      logger.debug "Duplicates of '#{named_entity.text}': #{group.map(&:text)}"

      named_entities.reject! { |ne| group.include?(ne) }
      duplicates << group.append(named_entity)
    end
    duplicates
  end

  def resolve(document, named_entities)
    duplicates = find_duplicates(named_entities.to_a)
    Person.populate(document, duplicates)
  end

  def jarowinkler_distance(a, b)
    jw = Amatch::JaroWinkler.new(a)
    jw.match(b)
  end

  def branting_distance(a, b)
    as, bs = [a, b].map { |w| w.split(" ") }
    shortest, longest = [as, bs].sort_by(&:size)
    scores = shortest.map do |a|
      jw = Amatch::JaroWinkler.new(a)
      scores = longest.map { |b| jw.match(b) }
      scores.max
    end
    scores.sum / shortest.size
  end
end
