class NamedEntity
  include Mongoid::Document

  field :text,      :type => String, :default => lambda { human_form }
  field :pos,       :type => Integer
  field :inner_pos, :type => Hash

  field :ne_class, :type => Symbol, :default => lambda { tag ? CLASSES_PER_TAG[tag] : nil }

  field :form,     :type => String
  field :lemma,    :type => String
  field :tag,      :type => String
  field :prob,     :type => Float
  field :tokens,   :type => Array

  belongs_to :document
  belongs_to :person
  has_and_belongs_to_many :pages

  validate :must_have_valid_position


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

  def must_have_valid_position
    return if inner_pos.nil?

    pages = {}
    text_lines = {}

    ["from", "to"].each do |key|
      # Existential and type validation
      if not inner_pos[key].is_a?(Hash)
        errors.add(:inner_pos, "#{key} is not a Hash")
        next
      end
      if not inner_pos[key]["pid"].is_a?(BSON::ObjectId)
        errors.add(:inner_pos, "#{key}[pid] is not a BSON::ObjectId")
      end
      if not inner_pos[key]["tlid"].is_a?(Fixnum)
        errors.add(:inner_pos, "#{key}[tlid] is not a Fixnum")
      end
      if not inner_pos[key]["pos"].is_a?(Fixnum)
        errors.add(:inner_pos, "#{key}[pos] is not a Fixnum")
      end

      # ObjectIds validation
      if not pages[key] = Page.find(inner_pos[key]["pid"])
        errors.add(:inner_pos, "#{key}[pid] references to a non-existent Page")
        next
      end
      if not text_lines[key] = pages[key].text_lines.find(inner_pos[key]["tlid"])
        errors.add(:inner_pos, "#{key}[tlid] references to a non-existent TextLine")
      end

      # Position out-of-range validation
      if inner_pos[key]["pos"] < 0 or inner_pos[key]["pos"] >= text_lines[key].text.size
        errors.add(:inner_pos, "#{key}[pos] is out of range")
        next
      end
    end

    return if not errors[:inner_pos].empty?

    # Different documents
    if pages["from"].document_id != pages["to"].document_id
      errors.add(:inner_pos, "from[pid] and to[pid] reference to Pages of different Documents")
    end

    # Range validation (from..to)
    if pages["from"].num > pages["to"].num or \
      (pages["from"].num == pages["to"].num and (text_lines["from"].id > text_lines["to"].id or \
        (text_lines["from"].id == text_lines["to"].id and inner_pos["from"]["pos"] > inner_pos["to"]["pos"])))
      errors.add(:inner_pos, "invalid range")
    end
  end
end
