require 'test_helper'

describe CSVExporterService do
  let(:document) { FactoryGirl.create :document }
  let(:exporter) { CSVExporterService.new(document) }

  describe '#document_info' do
    it '' do
      exporter.stubs(date: '11/11/11', link_to_doc: '/')
      exporter.document_info.must_equal [
        document.title, document.original_filename, '11/11/11', '/'
      ]
    end
  end

  describe '#link_to_file' do
    it '' do
      link = "http://mapa76.info/documents/#{document.id}/comb"

      exporter.link_to_doc.must_equal link
    end
  end

  describe '#original_filename' do
    it '' do
      exporter.original_filename.must_equal document.original_filename
    end
  end
end
