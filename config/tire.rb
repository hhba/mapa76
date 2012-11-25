class ProxyObject < SimpleDelegator
  delegate :class, :is_a?, :to => :_proxied_object

  def initialize(attrs={})
    klass = attrs['_type'].camelize.classify.constantize
    @_proxied_object = klass.find(attrs.delete("_mid"))
    _proxied_object["_search"] = attrs.select { |attr| attr.start_with?("_") }
    super(_proxied_object)
  end

  private

  def _proxied_object
    @_proxied_object
  end
end

Tire.configure do
  wrapper ProxyObject
end
