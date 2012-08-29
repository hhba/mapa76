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
    self.named_entities.where(:ne_class => :addresses)
  end
end