collection @results

node :id do |item|
  item.first.id
end

node :title do |item|
  item.first.title
end

node :created_at do |item|
  item[1].created_at
end

node :percentage do |item|
  item[1].percentage
end

node :counters do |item|
  {
    people: item[1].context_cache.fetch('people', []).count,
    organizations: item[1].context_cache.fetch('organizations', []).count,
    places: item[1].context_cache.fetch('places', []).count,
    dates: item[1].context_cache.fetch('dates', []).count
  }
end

node :highlight do |item|
  item.first.highlight
end
