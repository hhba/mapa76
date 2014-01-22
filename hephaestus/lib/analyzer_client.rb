require 'open3'
require "enumerator"
require "hashie/mash"
require "tempfile"

class AnalyzerClient
  class ExtractionError < StandardError
  end

  attr_reader :text, :opt, :port, :timeout, :size

  Token = Class.new(Hashie::Mash)

  def initialize(text, opt={})
    @text = text
    @size = text.size
    @port = opt.fetch(:port, 50005)
    @timeout = opt.fetch(:timeout, 10800) # Three hours
  end

  def call
    output = []
    file = Tempfile.new('foo', encoding: 'utf-8')
    begin
      file.write(text)
      file.close
      stdin, stdout, stderr = Open3.popen3(command(file.path))
      Timeout::timeout(timeout) {
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
    ensure
      file.close
      file.unlink
    end
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
        end

        pos = pos + ne_text.length
        logger.debug "#{pos}/#{size} | #{ne_text} | #{token_pos} | #{ne_regexp.inspect}"
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
         /#{ne_text.split('_').join('\W')}/i
      else
        /#{ne_text}/i
      end
    rescue RegexpError => e
      /./
    end
  end

  def command(file_path)
    logger.debug("[COMMAND] /usr/local/bin/analyzer_client #{port} < #{file_path}")
    "/usr/local/bin/analyzer_client #{port} < #{file_path}"
  end
end
