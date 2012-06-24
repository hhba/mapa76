class ExtractionTask
  @queue = :extraction

  ##
  # Perform a morphological analysis and extract named entities like persons,
  # organizations, places, dates and addresses.
  #
  # When finished, enqueue the coreference resolution task. Also, if any
  # addresses were found, enqueue the geocoding task.
  #
  def self.perform(document_id)
    doc = Document.find(document_id)
    doc.update_attribute :state, :extracting

    logger.info "Extract named entities from content"
    doc.named_entities.delete_all
    doc_iter = doc.new_iterator
    Analyzer.extract_named_entities(doc.text).each do |ne_attrs|
      pos = {}
      doc_iter.seek(ne_attrs[:pos])
      pos[:from] = {
        :page_id => doc_iter.page.id,
        :text_line_id => doc_iter.text_line.id,
        :pos => doc_iter.inner_pos,
      }
      last_token = ne_attrs[:tokens].last
      doc_iter.seek(last_token[:pos] + last_token[:form].size)
      pos[:to] = {
        :page_id => doc_iter.page.id,
        :text_line_id => doc_iter.text_line.id,
        :pos => doc_iter.inner_pos,
      }
      ne_attrs[:pos] = pos

      ne_klass = case ne_attrs[:ne_class]
        when :addresses then AddressEntity
        when :actions then ActionEntity
        else NamedEntity
      end

      ne = ne_klass.new(ne_attrs)
      ne.save!
      doc.named_entities << ne
    end

    logger.info "Count classes of named entities found"
    doc.information = {
      :people => doc.people.count,
      :people_ne => people_found.size,
      :dates_ne => dates_found.size,
      :organizations_ne => organizations_found.size
    }

    logger.info "Save document"
    doc.last_analysis_at = Time.now
    doc.save

    logger.info "Enqueue Coreference Resolution task"
    Resque.enqueue(CoreferenceResolutionTask, document_id)

    if doc.addresses_found.count > 0
      logger.info "Enqueue Geocoding task (#{doc.address_found.count} addresses found)"
      Resque.enqueue(GeocodingTask, document_id)
    end
  end
end
