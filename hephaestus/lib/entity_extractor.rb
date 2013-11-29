class EntityExtractor
  attr_reader :content, :options

  def initialize(content)
    @content = content
    @options = {
      config_path: File.join(APP_ROOT, "config", "freeling", "config", "es.cfg"),
      output_format: :tagged,
      memoize: false
    }
  end

  def call
    Enumerator.new do |yielder|
      pos = 0
      analyze(content).each do |token|
        ne_text = token['form'].dup
        ne_regexp = build_regexp(ne_text)
        pos = pos + (content[pos..-1] =~ ne_regexp)
        token.pos = pos
        yielder << token
        pos = pos + ne_text.length
      end
    end
  end

  def analyze(text)
    FreeLing::Analyzer.new(text, options).tokens
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
end
