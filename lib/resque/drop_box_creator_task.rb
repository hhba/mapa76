require "lib/resque/file_downloader"

class DropBoxCreatorTask

  @queue = :drop_box_creator

  def self.perform(document_links)
    drop_box_creator = self.new(document_links)
    drop_box_creator.save
    drop_box_creator.enqueue_processes
  end

  def initialize(document_links)
    @documents = []
    @document_links = document_params
    generate_documents
  end

  def generate_documents
    @documents = @document_params[:files].map do |file|
      download_file = FileDownloader.new file
      document = Document.new original_filename: download_file.filename
      document.original_filename = download_file.filename
      document.file = download_file.download
      document
    end
  end

  def save
    @documents.each { |document| document.save }
  end

  def enqueue_processes
    @documents.each { |document| document.enqueue_process }
  end
end