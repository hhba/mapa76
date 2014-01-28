collection @results
attributes :title, :original_filename, :document_id, :num, :text, :created_at, :highlight

# node :counters do |item|
#   {
#     people: item[1].context_cache.fetch('people', []).count,
#     organizations: item[1].context_cache.fetch('organizations', []).count,
#     places: item[1].context_cache.fetch('places', []).count,
#     dates: item[1].context_cache.fetch('dates', []).count
#   }
# end
