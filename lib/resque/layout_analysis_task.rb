class LayoutAnalysisTask
  @queue = :layout_analysis

  ##
  # Analyze document layout to determine optimized order of text lines for the
  # NERC analyzer.  Secondly, store processed text and position ranges for
  # locating a NamedEntity easily in a TextLine.
  #
  # When finished, enqueue the extraction task to detect and classify named
  # entities.
  #
  def self.perform(document_id)
    doc = Document.find(document_id)
    doc.update_attribute :state, :analyzing_layout

    logger.info "Perform geometric and logic layout analysis on document"
    blocks = self.analyze(doc)

    # FIXME normalize text lines in NormalizationTask, not here!

    logger.info "Normalize (squeeze and strip) text lines and store position ranges"
    pos = 0
    doc.processed_text = blocks.map do |block|
      block.map do |tl|
        tl.processed_text = self.squeeze_and_strip(tl.text)
        tl.from_pos = pos
        tl.to_pos = pos + tl.processed_text.size - 1
        tl.save
        pos += tl.processed_text.size + TextLine::SEPARATOR.size
        tl.processed_text
      end.join(TextLine::SEPARATOR)
    end.join(Document::BLOCK_SEPARATOR)

    logger.info "Save processed text"
    doc.save

    logger.info "Store pages position range"
    pages = {}
    blocks.each do |block|
      block.each do |tl|
        p_id = tl.page._id
        pages[p_id] ||= tl.page

        # Initialize page page
        pages[p_id].from_pos ||= doc.processed_text.size    # Max value
        pages[p_id].to_pos   ||= 0                          # Min value

        # Expand page range while iterating through every text line
        pages[p_id].from_pos = tl.from_pos if tl.from_pos < pages[p_id].from_pos
        pages[p_id].to_pos = tl.to_pos if tl.to_pos > pages[p_id].to_pos
      end
    end
    pages.values.each { |page| page.save }

    logger.info "Enqueue Extraction task"
    Resque.enqueue(ExtractionTask, document_id)
  end

private
  ##
  # Remove spaces in between characters and
  # strip whitespace from left and right
  #
  def self.squeeze_and_strip(string)
    new_string = string.strip
    it = 0
    while splitted = new_string.split and
         (splitted.select { |w| w.size == 1 }.count > 0.8 * splitted.size) and
          new_string.size > 1
      new_string.gsub!(/([\w\W])\s/, "\\1")
      it += 1
      raise "infinite loop?" if it > 100
    end
    new_string.strip
  end

  ##
  # Analyze document layout, determine optimized order of text lines
  # for the NERC analyzer, and return a list of blocks (grouped text lines).
  #
  # TODO:
  #   * Geometric layout analysis (maybe using XY-cuts)
  #   * Logic layout analysis (TODO investigate: supervised ML? ruled-based?)
  #
  def self.analyze(document)
    # NOTE For now, return only one cluster with all text lines
    # in the original "raw" reading order.
    [document.pages.all.sort_by(&:num).map { |p| p.text_lines.all.sort_by(&:num) }.flatten]
  end
end
