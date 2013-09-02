module Mongoid
  module References
    module ClassMethods
      def references(fields, opts={})
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
              klass.where(:id.in => (self.send("#{field_singular}_ids") || [])).to_a
            end
          end
        end
      end
    end

    module InstanceMethods
    end

    def self.included(receiver)
      receiver.extend         ClassMethods
      receiver.send :include, InstanceMethods
    end
  end
end
