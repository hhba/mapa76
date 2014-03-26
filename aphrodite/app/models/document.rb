class Document
  DOCUMENTS_LIMIT = 50
  validate :do_not_exceed_documents_limit

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

private

  def do_not_exceed_documents_limit
    if self.user && !self.user.admin? && (self.user.documents.count >= DOCUMENTS_LIMIT)
      errors.add(:documents_count, "Demasiados documentos")
    end
  end
end
