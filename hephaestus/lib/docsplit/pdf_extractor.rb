module Docsplit
  class PdfExtractor
    def version_string
      versionstr =  `#{office_executable} -h 2>&1`.split("\n").first
      if !!versionstr.match(/[0-9]*/)
        versionstr =  `#{office_executable} --version`.split("\n").first
      end
      @@help ||= versionstr
    end
  end
end
