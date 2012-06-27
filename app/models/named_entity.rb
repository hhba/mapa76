class NamedEntity
  include Mongoid::Document

  field :text,     :type => String, :default => lambda { human_form }
  field :pos,      :type => Hash

  field :ne_class, :type => Symbol, :default => lambda { tag ? CLASSES_PER_TAG[tag] : nil }

  field :form,     :type => String
  field :lemma,    :type => String
  field :tag,      :type => String
  field :prob,     :type => Float
  field :tokens,   :type => Array

  belongs_to :document
  belongs_to :page
  belongs_to :person

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
    content = self.document.content

    context_start = self.pos - length
    context_end = self.pos + self.form.size + length

    context_start = 0 if context_start < 0
    context_end = content.size if context_end > content.size

    content[context_start .. context_end]
  end

  def tag_to_s
    NamedEntity::CLASSES_PER_TAG[self.tag].to_s
  end


protected
  def human_form
    form.gsub('_', ' ') if form
  end

  def must_have_valid_position
    return if pos.nil?

    pages = {}
    text_lines = {}

    ["from", "to"].each do |pos_key|
      # Existential and type validation
      if not pos[pos_key].is_a?(Hash)
        errors.add(:pos, "#{pos_key} is not a Hash")
        next
      end
      if not pos[pos_key]["page_id"].is_a?(BSON::ObjectId)
        errors.add(:pos, "#{pos_key}[page_id] is not a BSON::ObjectId")
      end
      if not pos[pos_key]["text_line_id"].is_a?(BSON::ObjectId)
        errors.add(:pos, "#{pos_key}[text_line_id] is not a BSON::ObjectId")
      end
      if not pos[pos_key]["pos"].is_a?(Fixnum)
        errors.add(:pos, "#{pos_key}[pos] is not a Fixnum")
      end

      # ObjectIds validation
      if not pages[pos_key] = Page.find(pos[pos_key]["page_id"])
        errors.add(:pos, "#{pos_key}[page_id] references to a non-existent Page")
        next
      end
      if not text_lines[pos_key] = pages[pos_key].text_lines.find(pos[pos_key]["text_line_id"])
        errors.add(:pos, "#{pos_key}[text_line_id] references to a non-existent TextLine")
      end

      # Position out-of-range validation
      if pos[pos_key]["pos"] < 0 or pos[pos_key]["pos"] >= text_lines[pos_key].text.size
        errors.add(:pos, "#{pos_key}[pos] is out of range")
        next
      end
    end

    return if not errors[:pos].empty?

    # Different documents
    if pages["from"].document_id != pages["to"].document_id
      errors.add(:pos, "from[page_id] and to[page_id] reference to Pages of different Documents")
    end

    # Range validation (from..to)
    if pages["from"].num > pages["to"].num or \
      (pages["from"].num == pages["to"].num and (text_lines["from"].num > text_lines["to"].num or \
        (text_lines["from"].num == text_lines["to"].num and pos["from"]["pos"] > pos["to"]["pos"])))
      errors.add(:pos, "invalid range")
    end
  end
end
