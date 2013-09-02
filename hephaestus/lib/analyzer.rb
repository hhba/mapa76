# encoding: utf-8

# Define ENV variable for customizations to FreeLing default configurations
ENV['FREELING_CUSTOM'] ||= File.join(APP_ROOT, "config", "freeling")

module Analyzer
  LETTERS = 'áéíóúñüça-z'
  LETTERS_UPCASE = 'ÁÉÍÓÚÑÜA-Z'

  NP_RE = "(?:[#{LETTERS_UPCASE}][#{LETTERS}]+(?:[ ,](?:[#{LETTERS_UPCASE}][#{LETTERS_UPCASE}#{LETTERS}]+|(?:(?:de|la|del)(?= ))))*)"
  ADDRESS_RE = Regexp.new("(?<!^)((?:Av.? )?#{NP_RE}+ [0-9]{1,5}(?![0-9\/])(,? )?#{NP_RE}*)")

  ##
  # Return an enumerator of tokens
  #
  # All tokens have a reference to its position in the string
  # for locating it easily.
  #
  def self.extract_tokens(content, lang=:es)
    require "freeling/analyzer"

    Enumerator.new do |yielder|
      pos = 0
      analyzer = FreeLing::Analyzer.new(content, {
        :config_path => File.join(APP_ROOT, "config", "freeling", "config", "#{lang}.cfg"),
        :output_format => :splitted,
        :memoize => false,
      })
      analyzer.tokens.each do |token|
        token_pos = content.index(token[:form], pos)
        yielder << token.merge(:pos => token_pos)
        pos = token_pos + token[:form].size
      end
    end
  end

  ##
  # Return an enumerator of tokens with PoS tags
  #
  # NOTE This function works correctly *only if* the following FreeLing
  # config options are reset:
  #
  #   RetokContractions=no
  #   TaggerRetokenize=no
  #
  # When any of these are set, Dictionary or Tagger modules can retokenize
  # contracted words (e.g. "he's" => "he is"), changing the original text.
  # An exception is raised if this happens.
  #
  def self.extract_tagged_tokens(content, lang=:es)
    require "freeling/analyzer"

    Enumerator.new do |yielder|
      no_tokens = false
      total_size = content.size
      sentence_pos = 0

      st = self.extract_tokens(content, lang)
      begin
        cur_st = st.next
      rescue StopIteration
        no_tokens = true
      end

      unless no_tokens
        analyzer = FreeLing::Analyzer.new(content, {
          :config_path => File.join(APP_ROOT, "config", "freeling", "config", "#{lang}.cfg"),
          :output_format => :tagged,
          :memoize => false
        })
        analyzer.sentences.each do |sentence|
          sentence.each do |token|
            logger.debug "Token (#{cur_st[:pos]}/#{total_size}): #{token}"
            new_token = nil

            # exact match
            if token[:form] == cur_st[:form]
              new_token = token.merge(:pos => cur_st[:pos], :sentence_pos => sentence_pos)
              if NamedEntity::CLASSES_PER_TAG[token[:tag]]
                new_token[:tokens] = [{ :pos => cur_st[:pos], :form => cur_st[:form] }]
              end
              cur_st = st.next rescue nil

            # multiword
            # e.g. John Doe ==> tokens        = ["John", "Doe"]
            #                   tagged_tokens = ["John_Doe"]
            elsif token[:form] =~ /^#{cur_st[:form]}_/
              token_pos = cur_st[:pos]
              tokens = []
              m_word = token[:form].dup
              while not m_word.empty? and m_word.start_with?(cur_st[:form])
                tokens << { :pos => cur_st[:pos], :form => cur_st[:form] }
                m_word = m_word.slice(cur_st[:form].size + 1 .. -1).to_s
                cur_st = st.next rescue nil
              end
              new_token = token.merge(:pos => token_pos, :sentence_pos => sentence_pos)
              if NamedEntity::CLASSES_PER_TAG[token[:tag]]
                new_token[:tokens] = tokens
              end

            else
              raise "Simple tokens and tagged tokens do not match " \
                    "(#{cur_st[:form]} != #{token[:form]}). Maybe a contraction?"
            end

            # Classify!
            # TODO Separate this in another class/module/method...
            if ne_class = NamedEntity::CLASSES_PER_TAG[new_token[:tag]]
              new_token[:ne_class] = ne_class
            elsif ActionEntity.valid?(new_token)
              new_token[:ne_class] = :actions
            end

            yielder << new_token
          end
          sentence_pos += 1
        end
      end
    end
  end

  ##
  # Return an enumerator of named entities
  #
  def self.extract_named_entities(content, lang=:es)
    Enumerator.new do |yielder|
      self.extract_tagged_tokens(content, lang).each do |token|
        yielder << token if token[:ne_class]
      end
      self.extract_addresses(content, lang).each do |address|
        yielder << address
      end
    end
  end

  ##
  # Return an enumerator of addressese
  #
  def self.extract_addresses(content, lang=:es)
    Enumerator.new do |yielder|
      start_pos = 0
      loop do
        break if not content.match(ADDRESS_RE, start_pos) do |match|
          yielder << Hashie::Mash.new({
            :form => match[0].strip,
            :pos => match.begin(0),
            :ne_class => :addresses,
          })
          start_pos = match.end(0)
        end
      end
    end
  end
end
