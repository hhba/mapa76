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
end
