class Document
  DOCUMENTS_LIMIT = 50

  def flag!(user)
    update_attribute :flagger_id, user.id
  end

  def flagged?
    !!flagger_id
  end

  rails_admin do
    list do
      field :id
      field :title
      field :created_at do
        date_format :short
      end
      field :status
    end
  end
end
