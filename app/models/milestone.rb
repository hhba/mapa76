=begin
class Milestone < Sequel::Model
  many_to_one :person
  many_to_one :documents
=end
class Milestone
  include Mongoid::Document
  include Mongoid::Timestamps

  field :what, type: String
  field :where, type: String
  field :when, type: String
  field :date_from, type: String
  field :date_to, type: String

  belongs_to :person
  belongs_to :document

  def date_range(d)
    IncompleteDate.parse(d)
  end
  def date_from_range
    date_range(date_from)
  end
  def date_to_range
    date_range(date_to)
  end
  def self.where_list
    self.all.distinct(:where)
  end
  def self.what_list
    self.all.distinct(:what)
  end

  def source=(d)
    data=d.split("frag:doc=").last
    doc_id,fragment=data.split(":",2)
    self.document_id=doc_id
    pos = fragment.split("-",2)
    self.source_doc_fragment_start = pos.first
    self.source_doc_fragment_end   = pos.last
    super
  end
  def date_end=(v)
    v=nil if v.blank?
    super(v)
  end
end

#Milestone.plugin :json_serializer

