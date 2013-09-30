require 'csv'

class CsvGenerator
  attr_reader :document

  PEOPLE_COLUMNS = %W(DocumentID FullName Mentions Title Filename Date LinkToDoc)

  def initialize(document)
    @document = document
  end

  def title
  end

  def date
    @date ||= document.created_at.strftime("%m/%d/%Y - %H:%M")
  end

  def people
    document.people_found.each do |person|
      [
        document.id,
        person.full_name,
        person.mentions_in(document),
        document.title,
        document.filename,
        date
      ]
    end
  end
end
