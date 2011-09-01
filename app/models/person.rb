class Person < Sequel::Model
  one_to_many :milestones, :order => [:date_from, :date_to]
  many_to_many :documents
  def mentions_in(doc)
    DocumentsPerson.select(:mentions).first(:document_id => doc.id, :person_id => self.id).mentions
  end
  def self.normalize_name(name)
    ActiveSupport::Inflector.transliterate(name.to_s.downcase)
  end
  def self.filter_by_name(name,is_prefix=false)
    name +="%" if is_prefix
    self.filter(:searchable_name.like(normalize_name(name)))
  end
  def before_save
    self.searchable_name = self.class.normalize_name(name)
  end
end
Person.plugin :json_serializer

