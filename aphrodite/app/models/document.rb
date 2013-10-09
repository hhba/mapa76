class Document
  def flag!(user)
    update_attribute :flagger_id, user.id
  end

  def flagged?
    !!flagger_id
  end
end
