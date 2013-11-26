class Citation
  include Mongoid::Document

  field :text,      type: String
  field :pos,       type: Integer
  field :inner_pos, type: Hash

  belongs_to :document
  belongs_to :page

#  validate :must_have_valid_position

  def to_s
    text || super
  end

protected
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
      if not inner_pos[key]["pid"].is_a?(Moped::BSON::ObjectId)
        errors.add(:inner_pos, "#{key}[pid] is not a Moped::BSON::ObjectId")
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
