require_relative "citation"

class NamedEntity < Citation
  field :text,     type: String, default: lambda { human_form }

  field :ne_class, type: Symbol, default: lambda { tag ? CLASSES_PER_TAG[tag] : nil }

  field :form,     type: String
  field :lemma,    type: String
  field :tag,      type: String
  field :prob,     type: Float
  field :tokens,   type: Array

  belongs_to :person, index: true


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
    text = self.document.processed_text

    # Calculate "start" and "end"
    context_start = self.pos - length
    context_end = self.pos + self.text.size + length

    # Clamp values to document size
    context_start = 0 if context_start < 0
    context_end = text.size if context_end > text.size

    text[context_start .. context_end]
  end

  def tag_to_s
    NamedEntity::CLASSES_PER_TAG[self.tag].to_s
  end


protected
  def human_form
    form.gsub('_', ' ') if form
  end
end
