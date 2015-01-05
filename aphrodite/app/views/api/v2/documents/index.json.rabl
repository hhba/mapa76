collection @documents
attributes :id, :title, :created_at, :percentage, :url

node :counters do  |document|
  {
    people: document.context_cache.fetch('people', []).count,
    organizations: document.context_cache.fetch('organizations', []).count,
    places: document.context_cache.fetch('places', []).count,
    dates: document.context_cache.fetch('dates', []).count
  }
end

node :failed do |document|
  !document.valid?
end

node :error_messages do |document|
  document.errors.messages
end

node :document_index do |document|
  "#{@documents.to_a.index(document) + 1}/#{Document::DOCUMENTS_LIMIT}"
end
