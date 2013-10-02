require 'csv'

class CSVExporterService
  attr_reader :document

  def initialize(document, hostname='')
    @hostname = hostname.blank? ? 'http://mapa76.info/' : hostname
    @document = document
  end

  def export_people
    CSV.generate do |csv|
      csv << %w[PersonID Name Mentions].concat(document_info_str)
      document.people.each do |person|
        csv << [person.id, person.name, mentions(person), title, original_filename, date, document.id, link_to_doc]
      end
    end
  end

  def mentions(person)
    person.mentions.fetch(document.id.to_s, 0)
  end

  def export_dates
    export(:dates_found,
           %w{ document_id text lemma tag prob pos sentence_pos page_num time })
  end

  def export_places
    export([:places_found, :addresses_found],
           %w{ document_id text lemma tag prob pos sentence_pos page_num lat lng })
  end

  def export_organizations
    organization_groups = document.organizations_found.group_by(&:text)
    CSV.generate do |csv|
      csv << %w(Name Mentions).concat(document_info_str)
      organization_groups.each do |group|
        org = group.first
        csv << [org, group.count].concat(document_info)
      end
    end
  end

  def original_filename
    @original_filename ||= document.original_filename
  end

  def title
    @title ||= document.title
  end

  def date
    @date ||= document.created_at.strftime("%m/%d/%Y - %H:%M")
  end

  def link_to_doc
    "#{@hostname}documents/#{@document._id}/comb"
  end

  def document_info
    [document.title, original_filename, date, link_to_doc]
  end

  def document_info_str
    %w[Title Filename Date DocumentId link_to_doc]
  end

private

  def export(finders, keys)
    finders = Array(finders)
    CSV.generate do |csv|
      csv << keys + ['Title', 'Filename', 'Date', 'link_to_doc']
      finders.each do |finder|
        document.public_send(finder).each do |ne|
          row = keys.map { |k| ne.respond_to?(k) ? ne.public_send(k) : nil }
          row << title
          row << original_filename
          row << date
          row << link_to_doc

          csv << row
        end
      end
    end
  end
end
