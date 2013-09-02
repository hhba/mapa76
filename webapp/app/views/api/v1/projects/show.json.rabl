object @project
attributes :_id, :name, :description
child :documents, object_root: false do
  attributes :title
end
