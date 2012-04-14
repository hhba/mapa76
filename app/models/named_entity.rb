class NamedEntity
  include Mongoid::Document

  field :form,     :type => String
  field :pos,      :type => Integer
  field :ne_class, :type => Symbol, :default => lambda { tag ? CLASSES_PER_TAG[tag] : nil }
  field :lemma,    :type => String
  field :tag,      :type => String
  field :prob,     :type => Float
  field :tokens,   :type => Array

  embedded_in :document

  CLASSES_PER_TAG = {
    'NP00O00' => :organizations,
    'NP00V00' => :others,
    'NP00SP0' => :people,
    'NP00G00' => :places,
    'NP00000' => :unknown,
    'W'       => :dates,
    'NP00GA0' => :addresses,
  }

  def orginal_text
    document.content[pos...pos + form.size]
  end
end
