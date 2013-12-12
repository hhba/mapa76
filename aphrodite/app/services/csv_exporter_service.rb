require 'csv'

class CSVExporterService
  attr_reader :documents

  def initialize(documents = [], hostname='')
    @hostname = hostname.blank? ? 'http://analice.me/' : hostname
    @documents = documents
  end

  def export_people
    CSV.generate do |csv|
      documents.each do |document|
        csv << %w[PersonID Name Mentions].concat(document_info_str)
        document.people.each do |person|
          csv << [person.id, person.name, mentions_for(person, document)].
            concat(info_for(document))
        end
      end
    end
  end

  def export_places
    CSV.generate do |csv|
      documents.each do |document|
        csv << %w[PlaceID Name Mentions].concat(document_info_str)
        (document.addresses + document.places).each do |place|
          csv << [place.id, place.name, mentions_for(place, document)].
            concat(info_for(document))
        end
      end
    end
  end

  def export_organizations
    CSV.generate do |csv|
      documents.each do |document|
        csv << %w(OrganizationId Name Mentions).concat(document_info_str)
        document.organizations.each do |org|
          csv << [org.id, org.name, mentions_for(org, document)].
            concat(info_for(document))
        end
      end
    end
  end

  def export_dates
    CSV.generate do |csv|
      documents.each do |document|
        csv << %w(DateEntityId Name Lemma Mentions).concat(document_info_str)
        document.date_entities.each do |date|
          csv << [date.id, date.name, date.lemma, mentions_for(date, document)].
            concat(info_for(document))
        end
      end
    end
  end

  def mentions_for(entity, document)
    entity.mentions.fetch(document.id.to_s, 0)
  end

  def created_at(document)
    document.created_at.strftime("%m/%d/%Y - %H:%M")
  end

  def link_to(document)
    "#{@hostname}documents/#{document._id}/"
  end

  def info_for(document)
    [
      document.title,
      document.original_filename,
      created_at(document),
      link_to(document)
    ]
  end

  def document_info_str
    %w[Title Filename Date DocumentId link_to_doc]
  end
end
