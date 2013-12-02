collection @entities
attributes :id, :name

node :mentions do |entity|
  entity.mentions.map do |id, val|
    begin
      {id: id, title: Document.find(id).title, mentions: val}
    rescue Mongoid::Errors::DocumentNotFound
      nil
    end
  end.compact
end