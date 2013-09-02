object @project
attributes :id, :name, :description

child :documents do
  attributes :id, :title
  child :dates_found => :dates_found do
    attributes :text, :form
    node(:link)  { |ne| named_entity_link(ne) }
    node(:date) do |ne|
      { 
        day: day_from(ne.lemma),
        month: month_from(ne.lemma),
        year: year_from(ne.lemma)
      }
    end
    #node(:day)   { |ne| day_from(ne.lemma)   }
    #node(:month) { |ne| month_from(ne.lemma) }
    #node(:year)  { |ne| year_from(ne.lemma)  }
  end
end
