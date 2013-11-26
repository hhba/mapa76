# encoding: utf-8
require "test_helper"

describe ExtractionTask do
  let(:document) { FactoryGirl.create :document }
  let(:page) { FactoryGirl.create :page, from_pos: 0, to_pos: 10 }
  let(:extraction_task) { ExtractionTask.new(document.id) }

  before do
    document.pages << page
  end

  describe '#find_page' do
    it 'find correct page' do
      extraction_task.find_page(10).must_equal page
    end
  end

  describe '#build_regexp' do
    it 'builds normal regexp' do
      regexp = /Lorenzetti/
      extraction_task.build_regexp('Lorenzetti').must_equal regexp
    end

    it 'builds a special regexp' do
      regexp = /Ricardo\WLorenzetti/
      extraction_task.build_regexp('Ricardo_Lorenzetti').must_equal regexp
    end
  end
end
