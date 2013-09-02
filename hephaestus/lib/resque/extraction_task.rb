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
    Analyzer.extract_named_entities(doc.processed_text, doc.lang).each do |ne_attrs|
      inner_pos = {}

      doc_iter.seek(ne_attrs[:pos])
      inner_pos["from"] = {
        "pid" => doc_iter.page.id,
        "tlid" => doc_iter.text_line.id,
        "pos" => doc_iter.inner_pos,
      }

      last_token = (ne_attrs[:tokens] && ne_attrs[:tokens].last) || ne_attrs
      doc_iter.seek(last_token[:pos] + last_token[:form].size - 1)
      inner_pos["to"] = {
        "pid" => doc_iter.page.id,
        "tlid" => doc_iter.text_line.id,
        "pos" => doc_iter.inner_pos,
      }

      ne_attrs[:inner_pos] = inner_pos

      ne_klass = case ne_attrs[:ne_class]
        when :addresses then AddressEntity
        when :actions then ActionEntity
        else NamedEntity
      end

      ne = ne_klass.new(ne_attrs)
      ne.save!

      doc.named_entities << ne
      doc.pages.in(:_id => ["from", "to"].map{ |k| ne.inner_pos[k]["pid"] }.uniq).each do |page|
        page.named_entities << ne
      end
    end

    logger.info "Count classes of named entities found"
    doc.information = {
      :people => doc.people.count,
      :people_ne => doc.people_found.size,
      :dates_ne => doc.dates_found.size,
      :organizations_ne => doc.organizations_found.size
    }

    logger.info "Save document"
    doc.last_analysis_at = Time.now
    doc.percentage = 55
    doc.save

    logger.info "Enqueue Coreference Resolution task"
    Resque.enqueue(CoreferenceResolutionTask, document_id)

    # if doc.addresses_found.count > 0
    #   logger.info "Enqueue Geocoding task (#{doc.addresses_found.count} addresses found)"
    #   Resque.enqueue(GeocodingTask, document_id)
    # end
  end
end
