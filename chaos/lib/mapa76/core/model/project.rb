require 'uri'

class Project
  include Mongoid::Document

  field :name, :type => String
  field :slug, :type => String
  field :public, type: Boolean, default: false
  field :description, :type => String

  has_and_belongs_to_many :documents
  has_and_belongs_to_many :users
  
  validates :slug, uniqueness: true, on: :update
  
  before_save :escape_slug

  def add_document_by_id(document_id)
    documents << Document.find(document_id)
  end

  def remove_document_by_id(document_id)
    documents.delete Document.find(document_id)
  end
  
  def escape_slug
    self.slug = URI.escape(read_attribute(:slug).strip())
  end
end
