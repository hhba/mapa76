class Register
  include Mongoid::Document
  include Mongoid::Timestamps

  def self.actions
    ActionEntity::VERBS
  end

  # FIXME
  #def self.build_and_save(values)
  #  whats = values.delete("what")
  #  whats.map do |what|
  #    values["what"] = what
  #    self.create(values)
  #  end
  #end

protected
  def self.references(fields, opts={})
    raise ArgumentError, ":type option is missing" if not opts[:type]
    fields = Array(fields)
    klass = opts[:type]

    fields.each do |field|
      if field_singular = field.to_s.singularize.to_sym and field == field_singular
        define_method(field) do
          self.send("#{field}_id") and klass.find(self.send("#{field}_id"))
        end
      else
        define_method(field) do
          klass.where.in(id: (self.send("#{field_singular}_ids") || [])).to_a
        end
      end
    end
  end
end
