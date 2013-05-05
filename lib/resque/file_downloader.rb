require 'uri'
require 'net/http'

class FileDownloader
  attr_accessor :file

  def initialize(url)
    @uri = URI(url)
  end

  def download
    @file = Tempfile.new(filename, encoding: "ascii-8bit")
    Net::HTTP.start(host) do |http|
      resp = http.get(path)
      @file.write(resp.body)
    end
    @file
  end

  def filename
    @filename ||= @uri.path.split("/").last
  end

  def path
    @uri.path
  end

  def host
    @uri.host
  end
end