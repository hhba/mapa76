require 'open3'

ENV['FREELINGSHARE'] = '/usr/local/share/freeling'


module FreeLing
  class Analyzer
    attr_reader :document, :last_error

    DEFAULT_CONFIG_PATH = '/usr/local/share/freeling/config/es.cfg'
    DEFAULT_ANALYZE_PATH = '/usr/local/bin/analyzer'

    NotRunningError     = Class.new(StandardError)
    AnalyzerError       = Class.new(StandardError)


    def initialize(document, opts={})
      @document = document

      @options = {
        :config_path => DEFAULT_CONFIG_PATH,
        :analyze_path => DEFAULT_ANALYZE_PATH,
        :input_format => :plain,
        :output_format => :tagged,
        :memoize => true,
      }.merge(opts)

      unless File.exists?(@options[:analyze_path])
        raise "#{@options[:analyze_path]} not found"
      end

      unless File.exists?(@options[:config_path])
        raise "#{@options[:config_path]} not found"
      end

      @last_error_mutex = Mutex.new
    end

    def sentences(run_again=false)
      if @options[:output_format] == :plain
        raise "Sentence splitter is not available with output format set to 'plain'"
      end

      if not run_again and @sentences
        return @sentences.to_enum
      end

      Enumerator.new do |yielder|
        tokens = []
        read_tokens.each do |token|
          if token
            tokens << token
          else
            yielder << tokens
            if @options[:memoize]
              @sentences ||= []
              @sentences << tokens
            end
            tokens = []
          end
        end
      end
    end

    def tokens(run_again=false)
      if not run_again and @tokens
        return @tokens.to_enum
      end

      if @sentences
        @tokens ||= @sentences.flatten
        return @tokens.to_enum
      end

      Enumerator.new do |yielder|
        read_tokens.each do |token|
          if token
            yielder << token
            if @options[:memoize]
              @tokens ||= []
              @tokens << token
            end
          end
        end
      end
    end

    def close
      clean_process
    end


  private
    def command
      "#{@options[:analyze_path]} " \
        "-f #{@options[:config_path]} " \
        "--inpf #{@options[:input_format]} " \
        "--outf #{@options[:output_format]} " \
        "--nec " \
        "--noflush"
    end

    def run_process
      @stdin, @stdout, @stderr, @wait_thr = Open3.popen3(command)

      @write_thr = Thread.new do
        begin
          # TODO Read and write in chunks for better performance and lower
          # memory footprint. This is specially useful with large documents.
          str = @document.respond_to?(:read) ? @document.read : @document
          @stdin.write(str)
          @stdin.close_write
        rescue Errno::EPIPE
          @last_error_mutex.synchronize do
            @last_error = @stderr.read.chomp
          end
        end
      end
    end

    def clean_process
      close_fds
      kill_threads
      @stdin = @stdout = @stderr = nil
      @wait_thr = @write_thr = nil
    end

    def close_fds
      [@stdin, @stdout, @stderr].each do |fd|
        if fd and not fd.closed?
          fd.close
        end
      end
    end

    def kill_threads
      [@wait_thr, @write_thr].each do |thr|
        if thr and thr.alive?
          thr.kill
        end
      end
    end

    def read_tokens
      Enumerator.new do |yielder|
        if @stdout.nil?
          run_process
        end

        while line = @stdout.gets
          line.chomp!
          if line.empty?
            yielder << nil
          else
            yielder << parse_token_line(line)
          end
        end

        @stdout.close_read
        @write_thr.join
        clean_process
      end
    end

    def parse_token_line(str)
      form, lemma, tag, prob = str.split(' ')[0..3]
      { :form => form,
        :lemma => lemma,
        :tag => tag,
        :prob => prob,
      }.reject {|k, v| v.nil?}
    end
  end
end
