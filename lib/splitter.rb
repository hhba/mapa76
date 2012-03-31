require 'docsplit'

module Splitter
  def self.extract_plain_text(path)
    basename = File.basename(path, 'pdf')
    tmp_dir = Dir.tmpdir
    Docsplit.extract_text(path, :output => tmp_dir, :ocr => false)
    text = File.open(File.join(tmp_dir, basename + 'txt')).read
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

=begin
  def self.extract_text_from_pdf_string(str)
    tmp_file = Tempfile.new(["docsplit", ".pdf"], :encoding => "binary")
    tmp_file.write(str)
    tmp_file.close
    basename = File.basename(tmp_file.path, "pdf")
    tmp_dir = Dir.tmpdir
    Docsplit.extract_text(tmp_file.path, :output => tmp_dir, :ocr => false)
    open(File.join(tmp_dir, basename + "txt")).read
  end

  def self.extract_title_from_pdf_string(str)
    tmp_file = Tempfile.new(["docsplit", ".pdf"], :encoding => "binary")
    tmp_file.write(str)
    tmp_file.close
    basename = File.basename(tmp_file.path, "pdf")
    tmp_dir = Dir.tmpdir
    Docsplit.extract_title(tmp_file.path)
  end
=end
end
