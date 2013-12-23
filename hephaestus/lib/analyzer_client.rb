require 'open3'
require "enumerator"
require "hashie/mash"
require "tempfile"

class AnalyzerClient
  class ExtractionError < StandardError  
  end

  attr_reader :text, :opt, :port

  Token = Class.new(Hashie::Mash)

  def initialize(text, opt={})
    @text = text
    @port = opt.fetch(:port, 50005)
  end

  def call
    output = []
    file = Tempfile.new('foo', encoding: 'utf-8')
    begin
      file.write(text)
      stdin, stdout, stderr = Open3.popen3(command(file.path))
      begin
        status = Timeout::timeout(180) {
          until (line = stdout.gets).nil?
            output << line.chomp
          end

          message = stderr.readlines
          unless message.empty?
            raise ExtractionError, message.join("\n")
          end
        }
      rescue Timeout::Error
        raise ExtractionError, "Timeout"
      end
    ensure
      file.close
      file.unlink
    end
    # Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
    #   stdin.close
    #   until (line = stdout.gets).nil?
    #     output << line.chomp
    #   end

    #   message = stderr.readlines
    #   unless message.empty?
    #     raise ExtractionError, message.join("\n")
    #   end
    # end
    output
  end

  def tokens
    Enumerator.new do |yielder|
      pos = 0
      pre_tokens.each do |token|
        ne_text = token['form'].dup
        ne_regexp = build_regexp(ne_text)
        token_pos = text.index(ne_regexp, pos)
        if token_pos
          token.pos = token_pos
          yielder << token
          pos = token_pos + ne_text.length
        end
      end
    end
  end

  def pre_tokens
    Enumerator.new do |yielder|
      call.each do |freeling_line|
        yielder << parse_token_line(freeling_line) unless freeling_line.empty?
      end
    end
  end

  def parse_token_line(str)
    form, lemma, tag, prob = str.split(' ')[0..3]
    Token.new({
      :form => form,
      :lemma => lemma,
      :tag => tag,
      :prob => prob && prob.to_f,
    }.reject { |k, v| v.nil? })
  end

  def build_regexp(ne_text)
    begin
      if ne_text =~ /\_/
         /#{ne_text.split('_').join('\W')}/
      else
        /#{ne_text}/
      end
    rescue RegexpError => e
      /./
    end
  end

  def command(file_path)
    "analyzer_client #{port} < #{file_path}"
  end
end


__END__
FREELINGSHARE=/usr/local/Cellar/freeling/3.1/share/freeling analyzer -f es.cfg --server --port 50005 --workers 2 --queue 1
FREELINGSHARE=/usr/local/Cellar/freeling/3.1/share/freeling analyzer -f /usr/local/Cellar/freeling/3.1/share/freeling/config/es.cfg --server --port 50005 --workers 2 --queue 1
analyzer_client 50005 < rayuela2.txt