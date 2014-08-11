require 'uri'

class LinksUploaderService
  attr_reader :user, :bucket

  def initialize(bucket, user)
    @bucket = bucket.split("\n")
    @user = user
  end

  def valid?
    user.admin? || extralimit_documents?
  end

  def extralimit_documents?
    !(user.documents.length + bucket.size > Document::DOCUMENTS_LIMIT)
  end

  def call
    bucket.map { |url| Document.create url: url, user: user }
  end

  def temporal_title(url)
    uri = URI(url)
    uri.host.to_s + uri.path.to_s
  end
end
