collection @results
attributes :title, :original_filename, :document_id, :num, :text, :created_at, :counters, :highlight

node :id do |result|
  result.document_id
end