class Register
  include Mongoid::Document
  include Mongoid::Timestamps

  #field :who,    type: Array
  #field :when,   type: Array
  #field :where,  type: Array
  #field :to_who, type: Array
  #field :what,   type: String
  #
  #belongs_to :document, index: true
  #
  #def self.actions
  #  ActionEntity::VERBS
  #end
  #
  #def self.build_and_save(values)
  #  whats = values.delete("what")
  #  whats.map do |what|
  #    values["what"] = what
  #    self.create(values)
  #  end
  #end
  #
  #def to_hash
  #  {
  #    who:    self.who.map { |w| NamedEntity.find(w).text },
  #    what:   self.what,
  #    when:   self.when.map { |w| NamedEntity.find(w).text },
  #    where:  self.where.map { |w| NamedEntity.find(w).text },
  #    to_who: self.to_who.map { |w| NamedEntity.find(w).text }
  #  }
  #end

  # FIXME
  #def self.timeline_json
  #  all.map { |register| register.timeline_json }.reject {|r| !r}.to_json
  #end

  # FIXME
  #def timeline_json
  #  unless self.when.empty? or who.empty? or where.empty?
  #    { order: NamedEntity.find(self.when.first).timestamp, character: NamedEntity.find(who.first).text, group: NamedEntity.find(where.first).text }
  #  end
  #end

protected
  def self.references(fields, opts={})
    raise ArgumentError, ":type option is missing" if not opts[:type]
    fields = Array(fields)
    klass = opts[:type]

    fields.each do |field|
      define_method(field) do
        self.send("#{field}_id") and klass.find(self.send("#{field}_id"))
      end
    end
  end
end
