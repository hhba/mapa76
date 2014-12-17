require 'open-uri'
require 'tempfile'
require 'tmpdir'


class ExtractionTextTask < BaseTask
  @queue = 'io_queue'
  @msg = 'Extrayendo texto'

  def initialize(input)
    @url = input['metadata']['url']
    @document_id = input['metadata']['document_id']
    @metadata = input.fetch('metadata', {})
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
      'data' => text,
      'metadata' => metadata({
        'filename' => filename,
        'size' => text.size
      })
    }
  end

  def filename
    if @document_id.nil?
      @url.split('/')[-1]
    else
      document.original_filename
    end
  end

  def build_txt(filename)
    filename.split(".")[0..-2].join(".") + '.txt'
  end

  def get_content
    if @document_id.nil?
      open(@url, "rb") do |remote_file|
        remote_file.read
      end
    else
      output = ""
      document.file.each do |chunk|
        output << chunk
      end
      output
    end
  end

  def document
    @document ||= Document.find(@document_id)
  end
end
