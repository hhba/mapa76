object @person
attributes :id, :name

node :mentioned_in do |person|
  person.mentions.map do |id, val|
    begin
      {id: id, title: Document.find(id).title, mentions: val}
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end.compact
end
