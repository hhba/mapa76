class NamedEntity

  include Mongoid::Document

  field :form,     :type => String
  field :pos,      :type => Integer
  field :ne_class, :type => Symbol, :default => lambda { tag ? CLASSES_PER_TAG[tag] : nil }
  field :lemma,    :type => String
  field :tag,      :type => String
  field :prob,     :type => Float
  field :tokens,   :type => Array

  belongs_to :document
  belongs_to :person

  CLASSES_PER_TAG = {
    'NP00O00' => :organizations,
    'NP00V00' => :others,
    'NP00SP0' => :people,
    'NP00G00' => :places,
    'NP00000' => :unknown,
    'W'       => :dates,
    'NP00GA0' => :addresses,
  }

  def original_text
    @@content ||= {}
    @@content[document_id] ||= document.content
    @@content[document_id][pos ... pos + form.size]
  end

  def to_s
    original_text
  end

end
