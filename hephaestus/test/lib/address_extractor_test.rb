# encoding: utf-8
require 'test_helper'

describe AddressExtractor do
  it 'detects address in a sentence' do
    str = 'La casa rosada esta ubicada en Balcarce 50'
    address_extractor = AddressExtractor.new(str)

    address_extractor.call.first.pos.must_equal 31
  end
end