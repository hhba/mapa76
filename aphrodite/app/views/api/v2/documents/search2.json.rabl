collection @results
attributes :title, :original_filename, :document_id, :num, :text

node :result_type do |result|
  result._index.split('_')[0].singularize
end