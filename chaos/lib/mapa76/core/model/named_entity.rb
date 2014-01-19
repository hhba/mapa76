class NamedEntity < Citation
  include TimeSetter

  field :text,     type: String, default: lambda { human_form }

  field :ne_class, type: Symbol, default: lambda { tag ? CLASSES_PER_TAG[tag] : nil }

  field :form,        type: String
  field :lemma,       type: String
  field :tag,         type: String
  field :prob,        type: Float
  field :tokens,      type: Array
  field :collisioned, type: Boolean, default: false
  field :entity_id, type: Moped::BSON::ObjectId

  CLASSES_PER_TAG = {
    'NP00O00' => :organizations,
    'NP00V00' => :others,
    'NP00SP0' => :people,
    'NP00G00' => :places,
    'NP00000' => :unknown,
    'W'       => :dates,
    'ADDRESS' => :addresses
  }
  
  def self.valid_token?(token)
    !!CLASSES_PER_TAG[token]
  end

  def to_s
    text || human_form || super
  end

  def context(length=70, text=nil)
    text ||= self.document.processed_text

    # Calculate "start" and "end"
    context_start = self.pos - length
    context_end = self.pos + self.text.size + length

    # Clamp values to document size
    context_start = 0 if context_start < 0
    context_end = text.size if context_end > text.size

    text[context_start .. context_end]
  end

  def page_num
    if self.inner_pos
      Page.where(:_id => self.inner_pos["from"]["pid"]).only(:num).first.try(:num)
    end
  end

  def href
    # NOTE Doubly-sorry
    "http://mapa76.info/documents/#{document_id}/comb##{page_num}"
  end


protected
  def human_form
    form.gsub('_', ' ') if form
  end
end
