class Project
  def project_token
    self.users.first.access_token
  end
end
