class NamedEntity
  include Mongoid::Document

  field :form,     :type => String
  field :text,     :type => String, :default => lambda { human_form }
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
  }


  def to_s
    text || human_form || super
  end

  def context(length=50)
    content = self.document.content

    context_start = self.pos - length
    context_end = self.pos + self.form.size + length

    context_start = 0 if context_start < 0
    context_end = content.size if context_end > content.size

    content[context_start .. context_end]
  end


protected
  def human_form
    form.gsub('_', ' ') if form
  end
end
