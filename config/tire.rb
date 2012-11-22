class ProxyObject < SimpleDelegator
  delegate :class, :is_a?, :to => :_proxied_object

  def initialize(attrs={})
    puts "attrs: #{attrs}"
    klass = attrs['_type'].camelize.classify.constantize
    @_proxied_object = klass.new
    attrs["_es_id"] = attrs.delete("id")
    _assign_attrs(attrs)
    super(_proxied_object)
  end

  private

  def _proxied_object
    @_proxied_object
  end

  def _assign_attrs(attrs={})
    attrs.each_pair do |key, value|
      unless _proxied_object.respond_to?("#{key}=".to_sym)
        _proxied_object.class.send(:attr_accessor, key.to_sym)
      end
      _proxied_object.send("#{key}=".to_sym, value)
    end
  end
end

Tire.configure do
  wrapper ProxyObject
end
