class ExtractionTask < Base
  @queue = :extraction_task

  attr_reader :document, :progress_handler

  ##
  # Perform a morphological analysis and extract named entities like persons,
  # organizations, places, dates and addresses.
  #
  # When finished, enqueue the coreference resolution task. Also, if any
  # addresses were found, enqueue the geocoding task.
  #
  def self.perform(document_id)
    new(document_id).call
  end

  def initialize(id)
    @document = Document.find(id)
    @document.named_entities.destroy_all
    @progress_handler = ProgressHandler.new(document, bound: document.processed_text.size)
  end

  def call
    pos = 0
    analyze(document.processed_text).map do |token|
      if valid_token?(token)
        ne_text = token['form']
        ne_regexp = build_regexp(ne_text)
        pos = pos + (document.processed_text[pos..-1] =~ ne_regexp)

        puts "Searching for #{ne_text} in pos: #{pos}"
        page = find_page(pos)

        ne = store_named_entity(token, page, pos)
        page.named_entities << ne
        document.named_entities << ne

        pos = pos + ne_text.length
      end
      progress_handler.increment_to(pos)
    end
    logger.info "We found #{document.named_entities.count} named entities"
    document.save
  end

  def store_named_entity(token, page, pos)
    NamedEntity.create({
      form:  token['form'],
      lemma: token['lemma'],
      tag:   token['tag'],
      prob:  token['prob'],
      text:  token['form'],
      pos:   pos,
      inner_pos: { pid: page.id, from_pos: pos, to_pos: pos + token['form'].length }
    })
  end

  def analyze(text)
    analyzer = FreeLing::Analyzer.new(text, {
      :config_path => File.join(APP_ROOT, "config", "freeling", "config", "es.cfg"),
      :output_format => :tagged,
      :memoize => false
    })
    analyzer.tokens
  end

  def find_text(text, regexp, pos=0)
    text.index(regexp, pos)
  end

  def find_page(pos)
    document.pages.detect { |page| page.from_pos <= pos && pos <= page.to_pos }
  end

  def build_regexp(ne_text)
    if ne_text =~ /\_/
       /#{ne_text.split('_').join('\W')}/
    else
      /#{ne_text}/
    end
  end

  def valid_token?(token)
    !!NamedEntity::CLASSES_PER_TAG[token['tag']]
  end
end
