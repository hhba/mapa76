# encoding: utf-8

module Coreference

  MIN_SIMILARITY = 0.8

  def self.resolve(named_entities)
    output = []
    while !named_entities.empty?
      named_entity = named_entities.first
      jw = Amatch::JaroWinkler.new(named_entity.to_s)
      output << [name, named_entities.select { |ne| jw.match(ne.to_s) >= MIN_SIMILARITY }].flatten
      named_entities.reject! { |ne| output.flatten.include?(ne) }
    end
    output
  end

  def self.search_matching_groups(group, known_person)
    group.each do |name|
      return known_person if name_in_list?(name, known_person.names)
    end
    false
  end

  private

    def self.name_in_list?(name, list)
      list.each do |element|
        jw = Amatch::JaroWinkler.new(element)
        return true if jw.match(name) >= MIN_SIMILARITY
      end
      false
    end

end
