=begin
class ProxyObject < SimpleDelegator
  delegate :class, :is_a?, :to => :_proxied_object

  def initialize(attrs={})
    klass = attrs['_type'].camelize.classify.constantize
    @_proxied_object = klass.find(attrs.delete("_mid"))
    _proxied_object.attributes.keys.each { |a| attrs.delete(a) }
    _proxied_object["_search"] = attrs
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
=end
