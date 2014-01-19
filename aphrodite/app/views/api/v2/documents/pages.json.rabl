collection @pages
attributes :id, :num, :from_pos, :to_pos, :text

node :named_entities do |page|
  page.named_entities.ne(collisioned: true).asc(:pos).map do |ne|
    {
      id: ne.id,
      text: ne.text,
      ne_class: ne.ne_class,
      form: ne.form,
      pos: ne.pos,
      inner_pos: ne.inner_pos,
      entity_id: ne.entity_id
    }
  end
end
