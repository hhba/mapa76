require 'open-uri'
require 'tempfile'
require 'tmpdir'


class ExtractionTextTask < BaseTask
  @queue = 'extraction_text_task'
  @msg = 'Extracting text'

  def self.perform(input)
    self.new(JSON.parse(input)).call
  end

  def initialize(input)
    @url = input['data']
    @output = {}
  end

  def call
    text = ''

    Tempfile.open(filename) do |temp|
      temp.write(get_content)
      temp.close
      Dir.mktmpdir do |temp_dir|
        Docsplit.extract_text(temp.path, output: temp_dir)
        text = File.open(File.join(temp_dir, build_txt(filename))).read
        text = text.force_encoding('UTF-8')
      end
    end

    @output = {
      data: text,
      metadata: {
        url: @url,
        filename: filename,
        size: text.size,
        current_task: current_task
      }
    }
  end

  def filename
    @url.split('/')[-1]
  end

  def build_txt(filename)
    filename.split(".")[0..-2].join(".") + '.txt'
  end

  def get_content
    open(@url, "rb") do |remote_file|
      remote_file.read
    end
  end
end
