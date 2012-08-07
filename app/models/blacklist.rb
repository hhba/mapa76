# encoding: utf-8
require 'splitter'

class Blacklist

  include Mongoid::Document

  field :text, type: String
  has_many :named_entities

  validates_presence_of :text

end