object @document
attributes :id, :title, :description, :published_at, :created_at, :status, :percentage, :original_filename

node :counters do |document|
  {
    people: document.context_cache.fetch('people', []).count,
    organizations: document.context_cache.fetch('organizations', []).count,
    places: document.context_cache.fetch('places', []).count,
    dates: document.context_cache.fetch('dates', []).count
  }
end

node :pages do |document|
  document.page_ids.length
end