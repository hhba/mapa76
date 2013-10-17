require 'tempfile'
require 'open-uri'

class LinkService
  attr_reader :file_url, :user

  def initialize(file_url, user=nil)
    @file_url = file_url
    @user = user
  end

  def call
    begin
      Tempfile.open(filename, encoding: 'ascii-8bit') do |file|
        open(file_url, 'rb') do |read_file|
          file.write(read_file.read)
          file.rewind
          document = Document.new
          document.original_filename = filename
          document.file = file.path
          document.save

          user.documents << document if user
        end
      end
      true
    rescue Errno::ENOENT => e
      false
    end
  end

  def filename
    @filename ||= file_url.split('/')[-1]
  end
end
