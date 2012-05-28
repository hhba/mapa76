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
    
    @ne1 = NameEntity.new(1, "Luis Abelardo Patty")
    @ne2 = NameEntity.new(2, "Luis Ableardo Patty")
    @ne3 = NameEntity.new(3, "Luis Patty")
    @ne4 = NameEntity.new(4, "Jorge Rafael Videla")
    @ne5 = NameEntity.new(5, "Peperino Pomulo")
    @ne6 = NameEntity.new(6, "Luis Ableardo Patty")
    
    @named_entites = [@ne1, @ne2, @ne3, @ne4, @ne5, @ne6]
  end
  
  def test_find_duplicate
    processed = [
      [@ne1, @ne2, @ne3, @ne6], [@ne4], [@ne5]
    ]
    result = Coreference.find_duplicates(@named_entites)
    assert_equal processed, result, "Duplication"
  end

  def test_resolve
    document = Document.new(1)
    
    assert_equal 3, Coreference.resolve(document, @named_entities).count
  end
end

