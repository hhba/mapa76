require "docsplit"
module Docsplit
  def self.extract_text_from_pdf_str(str)
      tmp_file = Tempfile.new(["docsplit",".pdf"], :encoding => "binary")
      tmp_file.write(str)
      tmp_file.close
      basename = File.basename(tmp_file.path,"pdf")
      tmp_dir = Dir.tmpdir
      Docsplit.extract_text(tmp_file.path,:output => tmp_dir, :ocr => false)
      open(File.join(tmp_dir,basename+"txt")).read
  end
  def self.extract_title_from_pdf_str(str)
      tmp_file = Tempfile.new(["docsplit",".pdf"], :encoding => "binary")
      tmp_file.write(str)
      tmp_file.close
      basename = File.basename(tmp_file.path,"pdf")
      tmp_dir = Dir.tmpdir
      Docsplit.extract_title(tmp_file.path)
  end
  def self.clean_text(str)
    ret = str.dup
    ret = self.clean_line_numbers(ret)
    header = find_header(ret)
    if header
      ret = ret.gsub(header,"") 
    end
    ret
  end
  def self.clean_line_numbers(str)
    "clean line numbers" 
    str.gsub(/\n\n[0-9]+\n\n\f/,"\n")
  end
  def self.find_header(str)
    "finds the longest repeating header"
    sample = str[0...40024]
    newline = sample.index(/\r\n/) ? "\r\n" : "\n"
    lines = sample.split(/\r?\n/)
    (1 ... 20).each{|header_lines|
      header = lines[0 .. header_lines].join(newline)
      matches = sample.scan(Regexp.new(header)).size
#      puts "Trying a header of #{header_lines} matches: #{matches} - #{header.inspect} "
      if matches == 1 
#        puts "header seems to be #{header_lines} long"
        return lines[0...header_lines].join(newline) + newline
      end
    }
    nil
  end
end
