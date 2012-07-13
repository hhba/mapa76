# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class NameEntity
  attr_accessor :text, :id, :person_id, :metadata, :person

  def initialize(id, text)
    @text = text
    @id = id
  end

  def method_missing(sym)
    true
  end
end

class Document
  attr_accessor :id

  def initialize(id)
    @id = id
  end
end

class TestCoreference < Test::Unit::TestCase
  def setup
    @patty1 = NameEntity.new(1, "Luis Abelardo Patty")
    @patty2 = NameEntity.new(2, "Luis Ableardo Patty")
    @patty3 = NameEntity.new(3, "Luis Patty")
    @videla1 = NameEntity.new(4, "Jorge Rafael Videla")
    @pomulo1 = NameEntity.new(5, "Peperino Pomulo")
    @patty4 = NameEntity.new(6, "Luis Ableardo Patty")
    
    @named_entities = [@patty1, @patty2, @patty3, @videla1, @pomulo1, @patty4]
  end
  
  def test_find_duplicates
    processed = [
      [@patty1, @patty2, @patty4], [@patty3], [@videla1], [@pomulo1]
    ]
    result = Coreference.find_duplicates(@named_entities)
    assert_equal processed, result, "Duplication"
  end

  def test_resolve
    document = Document.new(1)
    assert_equal 3, Coreference.resolve(document, @named_entities).count
  end
end

