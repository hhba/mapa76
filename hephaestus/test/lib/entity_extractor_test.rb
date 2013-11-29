# encoding: utf-8

require 'test_helper'

describe EntityExtractor do
  it 'Finds right positions' do
    str = "Alegato fiscal. Causa “Campo de Mayo III”. Diciembre 2010."
    entity_extractor = EntityExtractor.new(str)

    positions = [0, 8, 14, 16, 21, 23, 29, 32, 37, 40, 41, 43, 53, 57]
    entity_extractor.call.map { |t| t.pos }.must_equal positions
  end
end