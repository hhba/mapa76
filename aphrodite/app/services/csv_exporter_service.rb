require 'csv'

class CSVExporterService
  attr_reader :document

  def initialize(document, hostname='')
    @hostname = hostname.blank? ? 'http://mapa76.info/' : hostname
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

  def link_to_doc
    "#{@hostname}documents/#{@document._id}"
  end

private

  def export(finders, keys)
    finders = Array(finders)
    CSV.generate do |csv|
      csv << keys.push('link_to_doc')
      finders.each do |finder|
        document.public_send(finder).only(*keys).each do |ne|
          row = keys.map { |k| ne.respond_to?(k) ? ne.public_send(k) : nil }
          row << link_to_doc
          csv << row
        end
      end
    end
  end
end
