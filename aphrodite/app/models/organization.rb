class Organization
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