class Project
  include Mongoid::Document

  field :name, :type => String
  field :description, :type => String

  has_and_belongs_to_many :documents
  has_and_belongs_to_many :users

  def add_document_by_id(document_id)
    documents << Document.find(document_id)
  end

  def remove_document_by_id(document_id)
    documents.delete Document.find(document_id)
  end
end
