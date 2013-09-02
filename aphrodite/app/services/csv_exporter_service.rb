require 'csv'

class CSVExporterService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def export_people
    export(:people_found,
           %w{ _id document_id text lemma tag prob pos sentence_pos })
  end

  def export_dates
    export(:dates_found,
           %w{ _id document_id text lemma tag prob pos sentence_pos time })
  end

  def export_places
    export([:places_found, :addresses_found],
           %w{ _id document_id text lemma tag prob pos sentence_pos lat lng })
  end

  def export_organizations
    export(:organizations_found,
           %w{ _id document_id text lemma tag prob pos sentence_pos })
  end

  def original_filename
    document.original_filename
  end

private

  def export(finders, keys)
    finders = Array(finders)
    CSV.generate do |csv|
      csv << keys
      #text = document.processed_text
      finders.each do |finder|
        document.public_send(finder).only(*keys).each do |ne|
          row = keys.map { |k| ne.respond_to?(k) ? ne.public_send(k) : nil }
          #row << ne.context(70, text)
          csv << row
        end
      end
    end
  end
end
