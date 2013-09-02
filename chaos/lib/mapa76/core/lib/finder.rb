module Finder
  def people_found
    self.named_entities.where(:ne_class => :people)
  end

  def dates_found
    self.named_entities.where(:ne_class => :dates)
  end

  def organizations_found
    self.named_entities.where(:ne_class => :organizations)
  end

  def places_found
    self.named_entities.where(:ne_class => :places)
  end

  def addresses_found
    Citation.where(:ne_class => :addresses, document_id: self.id)
  end

  def time_setter
    dates_found.map { |dated_entity| dated_entity.to_time_setter }
  end

  def graphicable_dates
    dates_found.select { |dated_entity| dated_entity.string_date? }.map { |dated_entity| dated_entity.to_time_setter }
  end
end


