class DocumentIterator
  attr_reader :pos
  attr_reader :page, :text_line, :inner_pos

  def initialize(document)
    @document = document
    seek(0)
  end

  def seek(pos)
    @document.pages.where(:from_pos.lte => pos, :to_pos.gte => pos).each do |p|
      if tl = p.text_lines.where(:from_pos.lte => pos, :to_pos.gte => pos).first
        @page = p
        @text_line = tl
        @inner_pos = pos - @text_line.from_pos
        return true
      end
    end
    return false
  end

  def pos=(new_pos)
    seek(pos)
  end
end
