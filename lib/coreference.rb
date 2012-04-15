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
    known_names = known_person.map { |km| km.names }
    known_names.each do |km|
      return known_person if match_groups(group, km)
    end
    nil
  end

  private

    def self.match_groups(list1, list2)
      list1.each do |element1|
        jw = Amatch::JaroWinkler.new(element1)
        list2.each do |element2|
          return true if jw.match(element2) >= MIN_SIMILARITY
        end
      end
      false
    end

end
