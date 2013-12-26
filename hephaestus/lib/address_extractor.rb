# encoding: utf-8

require "hashie/mash"

class AddressExtractor
  attr_reader :content

  Token = Class.new(Hashie::Mash)

  LETTERS = 'áéíóúñüça-z'
  LETTERS_UPCASE = 'ÁÉÍÓÚÑÜA-Z'

  NP_RE = "(?:[#{LETTERS_UPCASE}][#{LETTERS}]+(?:[ ,](?:[#{LETTERS_UPCASE}][#{LETTERS_UPCASE}#{LETTERS}]+|(?:(?:de|la|del)(?= ))))*)"
  ADDRESS_RE = Regexp.new("(?<!^)((?:Av.? )?#{NP_RE}+ [0-9]{1,5}(?![0-9\/])(,? )?#{NP_RE}*)")

  def initialize(content)
    @content = content
  end

  def call
    Enumerator.new do |yielder|
      start_pos = 0
      loop do
        break if not content.match(ADDRESS_RE, start_pos) do |match|
          yielder << Token.new({form: match[0].strip, tag: 'ADDRESS', pos: match.begin(0)})
          start_pos = match.end(0)
        end
      end
    end
  end
end
