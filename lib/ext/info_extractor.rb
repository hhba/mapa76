module Docsplit
  class InfoExtractor
    # Pull out a single datum from a pdf.
    def extract(key, pdfs, opts)
      pdf = [pdfs].flatten.first
      cmd = "pdfinfo #{ESCAPE[pdf]} 2>&1"
      result = `#{cmd}`.chomp

      # FIX encoding issues
      result.encode('UTF-8', :invalid => :replace, :replace => '').encode('UTF-8')

      raise ExtractionFailed, result if $? != 0 
      match = result.match(MATCHERS[key])
      answer = match && match[1]
      answer = answer.to_i if answer && key == :length
      answer
    end 
  end
end
