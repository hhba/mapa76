require "csv"

class Document
  def lang
    self.app == :mapa76 ? :es : :en
  end

  def to_csv
    heading = %w(name, fuerza, etiqueta)
    CSV.generate do |csv|
      csv << heading
      people.each do |person|
        csv << [person.name, person.force, person.tags.inspect]
      end
    end
  end

  def resolve_coreference
    Coreference.resolve(self, self.people_found)
    self
  end

  # TODO option for a range of pages
  def text(options={})
    self.pages.sort_by(&:num).map(&:text).join(Page::SEPARATOR)
  end

  def new_iterator
    DocumentIterator.new(self)
  end
end
