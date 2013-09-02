collection @projects
attributes :_id, :name, :description
child :documents do
  attributes :title, :_id
end
