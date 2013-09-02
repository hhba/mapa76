# encoding: utf-8
require 'amatch'

module Coreference
  extend self

  MIN_SIMILARITY = 0.92

  def resolve(document, named_entities)
    named_entities = remove_blacklisted(named_entities)
    # one_words = find_one_words(named_entities)
    named_entities = remove_one_word(named_entities)
    duplicates = find_duplicates(named_entities)

    # Person.populate(document, one_words)
    Person.populate(document, duplicates)
  end

  def find_one_words(named_entities)
    named_entities.select { |ne| ne.text.split.length == 1 }
  end

  def find_duplicates(named_entities, method=:branting)
    distance_method = "#{method}_distance".to_sym

    duplicates = []
    while !named_entities.empty?
      named_entity = named_entities.shift

      group = named_entities.select do |ne|
        send(distance_method, named_entity.text, ne.text) >= MIN_SIMILARITY
      end
      logger.debug "There are still #{named_entities.count}"
      logger.debug "Duplicates of '#{named_entity.text}': #{group.map(&:text)}"

      named_entities.reject! { |ne| group.include?(ne) }
      duplicates << group.append(named_entity)
    end
    duplicates
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

  def remove_blacklisted(named_entities)
    blacklisted = Blacklist.all.map(&:text)
    named_entities.reject { |ne| blacklisted.include?(ne.text) }
  end

  def remove_one_word(named_entities)
    named_entities.reject { |ne| ne.text.split.length == 1 }
  end
end
