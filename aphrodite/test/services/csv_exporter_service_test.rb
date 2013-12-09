require 'test_helper'
require 'csv'

describe CSVExporterService do
  let(:document) { FactoryGirl.create :document }
  let(:organization) { FactoryGirl.create :organization }
  let(:person) { FactoryGirl.create :person }
  let(:address) { FactoryGirl.create :address }
  let(:exporter) { CSVExporterService.new [document]}

  before do
    document.organizations << organization
    document.people << person
    document.addresses << address
    organization.update_attribute :mentions, {document.id.to_s => 2}
    person.update_attribute :mentions, {document.id.to_s => 4}
    address.update_attribute :mentions, {document.id.to_s => 1}
  end

  describe '#mentions_for' do
    it 'returns mentions for a document' do
      exporter.mentions_for(organization, document).must_equal 2
    end
  end

  describe '#info_for' do
    it 'returns info for a document' do
      exporter.info_for(document).must_include document.title
      exporter.info_for(document).must_include document.original_filename
    end
  end

  describe '#link_to' do
    it 'returns link to a document' do
      exporter.link_to(document).must_equal(
        "http://analice.me/documents/#{document.id}/"
      )
    end
  end

  describe '#created_at' do
    it 'returns created_at for a document' do
      exporter.created_at(document).must_equal(
        document.created_at.strftime("%m/%d/%Y - %H:%M")
      )
    end
  end

  describe '#export_organizations' do
    it '' do
      csv = CSV.parse(exporter.export_organizations)
      csv[-1].must_include organization.name
      csv[-1].must_include document.title
      csv[-1].must_include '2'
    end
  end

  describe '#export_people' do
    it '' do
      csv = CSV.parse(exporter.export_people)
      csv[-1].must_include person.name
      csv[-1].must_include document.title
      csv[-1].must_include '4'
    end
  end

  describe '#export_places' do
    it '' do
      csv = CSV.parse(exporter.export_places)
      csv[-1].must_include address.name
      csv[-1].must_include document.title
      csv[-1].must_include '1'
    end
  end

  #it 'export to csv' do
    #exporter = CSVExporterService.new('http://localhost:3000')
    #exporter.documents = [document]
    #exporter.export_people
  #end

  #describe '#document_info' do
    #it '' do
      #exporter.stubs(date: '11/11/11', link_to_doc: '/')
      #exporter.document_info.must_equal [
        #document.title, document.original_filename, '11/11/11', '/'
      #]
    #end
  #end

  #describe '#link_to_file' do
    #it '' do
      #link = "http://mapa76.info/documents/#{document.id}/comb"

      #exporter.link_to_doc.must_equal link
    #end
  #end

  #describe '#original_filename' do
    #it '' do
      #exporter.original_filename.must_equal document.original_filename
    #end
  #end
end
