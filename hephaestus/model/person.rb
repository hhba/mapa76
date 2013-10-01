class Person
  def self.conadep
    Person.all.select { |person| person.tags.include?("conadep")}
  end

  def self.populate(document, duplicates, opts={})
    # This is a really ugly code, but it works, I'm not gonna change it now!
    tags = opts.fetch :tags, []
    confidence = opts[:confidence] ? opts[:confidence] : 0.0

    output = []
    duplicates.each do |group|
      already_added = group.map do |ne|
        where(user_id: document.user_id).searchable_with(ne.text).first
      end.compact

      if already_added.empty?
        person = Person.create(:name => group.first.text,
                               :tags => tags,
                               :confidence => confidence,
                               :user_id => document.user_id,
                              )
      else
        person = already_added.first
      end
      person.named_entities.concat(group)
      person.documents << document
      person.save!
      output << person
    end
    output
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
