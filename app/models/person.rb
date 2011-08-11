class Person < Sequel::Model
  one_to_many :milestones
  many_to_many :documents
  def mentions_in(doc)
    DocumentsPerson.select(:mentions).first(:document_id => doc.id, :person_id => self.id).mentions
  end
  def self.normalize_name(name)
    ActiveSupport::Inflector.transliterate(name.to_s.downcase)
  end
  def self.filter_by_name(name)
    self.filter(:searchable_name => normalize_name(name)) 
  end
  def before_save
    self.searchable_name = self.class.normalize_name(name)
  end
end
Person.plugin :json_serializer

