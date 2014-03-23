class Project
  def self.find_by_slug(slug)
    where(slug: slug).first
  end

  def project_token
    self.users.first.access_token
  end
end
