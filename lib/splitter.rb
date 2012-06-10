require 'docsplit'

module Splitter
  def self.extract_title(path)
    Docsplit.extract_title(path)
  end

  def self.extract_plain_text(path)
    basename = File.basename(path).split('.')[0..-2].join('.')
    tmp_dir = Dir.tmpdir
    Docsplit.extract_text(path, :output => tmp_dir, :ocr => false)
    text = File.open(File.join(tmp_dir, "#{basename}.txt")).read
    self.clean_text(text)
  end

  def self.clean_text(str)
    ret = str.dup
    header = self.find_header(ret)
    ret = self.clean_line_numbers(ret)
    if header
      ret = ret.gsub(header, "")
    end
    ret
  end

  # Clean line numbers
  def self.clean_line_numbers(str)
    str.gsub(/\n\n?[0-9]+\n\n\f/, "\n")
  end

  # Finds the longest repeating header
  def self.find_header(str)
    sample = str[0 ... 40004]
    newline = sample.index(/\r\n/) ? "\r\n" : "\n"
    lines = sample.split(/\r?\n/)
    (1 ... 20).each do |header_lines|
      header = lines[0 ... header_lines].join(newline)
      matches = sample.scan(Regexp.new("\f#{header}")).size
      # puts "Trying a header of #{header_lines} lines matches: #{matches} - #{header.inspect} "
      if matches == 0
        ret = lines[0 ... header_lines - 1].join(newline)
        ret += newline if not ret.end_with?(newline)
        # puts "header seems to be #{header_lines - 1} long: ----\n#{ret}----"
        return ret
      end
    end
    nil
  end

  # Export the first page of a document as a PNG file as a thumbnail of a
  # document.
  def self.create_thumbnail(path, opts={})
    opts = {
      :size => '65x80'
    }.merge(opts)

    basename = File.basename(path).split('.')[0..-2].join('.')
    filename = basename + '.png'

    Docsplit.extract_images(path, opts.merge(:pages => 1))

    return "#{basename}_1.png"
  end
end
