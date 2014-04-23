class DocumentUploaderService
  attr_reader :files, :user

  def initialize(files, user)
    @files = files
    @user = user
  end

  def valid?
    user.admin? || extralimit_documents?
  end

  def extralimit_documents?
    !(user.documents.length + files.length > Document::DOCUMENTS_LIMIT)
  end

  def call
    files.map do |file|
      document = Document.new
      document.original_filename = file.original_filename
      document.file = file.path
      user.documents << document
      document.user = user
      document.save
      document
    end
  end
end