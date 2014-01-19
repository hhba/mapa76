collection @entities
attributes :id, :name

node :mentions do |entity|
  entity.mentions.map do |id, val|
    build_mention(id, val, @documents)
  end.compact
end