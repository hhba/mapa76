class Person
  def metainfo
    docs = documents.map { |doc| { id: doc._id, name: doc.title } }

    { _id: _id,
      created_at: created_at,
      documents: docs,
      full_name: full_name,
      tags: tags }
  end

  rails_admin do
    list do
      field :id
      field :name
      field :lemma
      field :created_at do
        date_format :short
      end
    end
  end
end
