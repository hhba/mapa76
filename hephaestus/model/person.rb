class Person
  #after_save :update_mentions

  def self.conadep
    Person.all.select { |person| person.tags.include?("conadep")}
  end

  def self.filter_by_name(name, is_prefix=false)
    #name +="%" if is_prefix
    #self.filter(:searchable_name.like(normalize_name(name)))
    regexp = "^#{normalize_name(name)}"
    regexp << '.*' if is_prefix
    self.where(searchable_name: Regexp.new(regexp))
  end

  def self.get_id_by_name(name)
    person = filter_by_name(name).first
    person.id if person
  end

  def names
    if name.nil?
      self.named_entities.collect { |ne| ne.text.downcase }
    else
      [self.name.downcase]
    end
  end
end
