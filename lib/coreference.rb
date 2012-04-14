# encoding: utf-8

class Coreference
  attr_accessor :named_entities

  MIN_SIMILARITY = 0.8

  def initialize(named_entities)
    @named_entities = named_entities
  end

  def resolve
    output = []
    while !named_entities.empty?
      name = named_entities.first
      jw = Amatch::JaroWinkler.new(name)
      output << [name, named_entities.select { |ne| jw.match(ne) >= MIN_SIMILARITY }].flatten
      named_entities.reject! { |ne| output.flatten.include?(ne) }
      puts named_entities.size
    end
    output.map do |group|
      main_name = group.max { |a, b| a.size <=> b.size }
      { main_name => group[1..-1] }
    end
  end
end
