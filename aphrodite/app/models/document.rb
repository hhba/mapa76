class Document
  def flag!(user)
    update_attribute :flagger_id, user.id
  end
end
