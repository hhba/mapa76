# encoding: utf-8
require "spec_helper"

describe Person do
  describe "add new person" do
    before do
      @p1 = create :person, name: "Luciano Benjamín MenÉndez", tags: ['procesados']
      @p2 = create :person, name: "Eduardo Massera", tags: ['procesados', 'condenados', 'condenados']
    end

    it "should not add an existing person" do
      Person.add "Luciano Benjamín MenÉndez", tag: 'condenados'

      assert_equal 2, Person.first.tags.length
    end

    it "should have unique tags" do
      assert_equal 2, @p2.tags.length
    end
  end

  describe "Blacklist" do
    before do
      @person = create :person, name: "Policia Federal"
      @person.blacklist
    end

    it "should not find the user once it was marked as blacklist" do
      assert_raises(Mongoid::Errors::DocumentNotFound) do
        Person.find(@person.id)
      end
    end
  end
end
