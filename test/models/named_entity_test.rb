# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class TestNamedEntity < Test::Unit::TestCase
  context "Parse date" do
    setup do
      @date_entity_1 = create :date_entity
      @date_entity_2 = create :date_entity, :lemma => "[??:??/7/2011:??.??:??]"
      @date_entity_3 = create :date_entity, :lemma => "[??:14/7/????:??.??:??]"
      @date_entity_4 = create :date_entity, :lemma => "nothing to do"
    end

    should "get string version of the date" do
      assert_equal "14/7/2011", @date_entity_1.string_date
      assert_equal "01/7/2011", @date_entity_2.string_date
      assert_equal nil, @date_entity_3.string_date
      assert_equal nil, @date_entity_4.string_date
    end

    should "Should parse date" do
      assert_equal Time.parse("14/07/2011"), @date_entity_1.time
      assert_equal Time.parse("01/07/2011"), @date_entity_2.time
      assert_equal nil, @date_entity_3.string_date
      assert_equal nil, @date_entity_4.string_date
    end

    should "Retrieve timestamp" do
      assert_instance_of Fixnum, @date_entity_1.timestamp
    end

    should "tell you when it does not have a parseable date" do
      assert @date_entity_1.string_date?
      assert_equal false, @date_entity_4.string_date?
    end

    should "Retrieve hash with information to time_setter" do
      def @date_entity_1.page_num
        1
      end

      def @date_entity_1.context
        "14 de julio de 2011"
      end

      time_setter_hash = {
        :date => "14/7/2011",
        :display_date => "14/7/2011",
        :description => "14 de julio de 2011",
        :link => "/documents/#{@date_entity_1.document.id}/comb#1",
        :series => "",
        :html => "",
        :timestamp => 1310612400
      }
      
      assert_equal time_setter_hash, @date_entity_1.to_time_setter
    end
  end
end
