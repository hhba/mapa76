class Person < Sequel::Model
  one_to_many :milestones
  many_to_many :documents
  def mentions_in(doc)
    DocumentsPerson.select(:mentions).first(:document_id => doc.id, :person_id => self.id).mentions
  end
end
Person.plugin :json_serializer

