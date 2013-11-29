require "spec_helper"

describe NamedEntity do
  describe "Parse date" do
    before do
      @date_entity_1 = create :date_entity
      @date_entity_2 = create :date_entity, :lemma => "[??:??/7/2011:??.??:??]"
      @date_entity_3 = create :date_entity, :lemma => "[??:14/7/????:??.??:??]"
      @date_entity_4 = create :date_entity, :lemma => "nothing to do"
    end

    it "Checks if a token is valid" do
      NamedEntity.valid_token? 'NP00O00'
    end

    it "should get string version of the date" do
      assert_equal "14/7/2011", @date_entity_1.string_date
      assert_equal "01/7/2011", @date_entity_2.string_date
      assert_equal nil, @date_entity_3.string_date
      assert_equal nil, @date_entity_4.string_date
    end

    it "should parse date" do
      assert_equal Time.parse("14/07/2011"), @date_entity_1.time
      assert_equal Time.parse("01/07/2011"), @date_entity_2.time
      assert_equal nil, @date_entity_3.string_date
      assert_equal nil, @date_entity_4.string_date
    end

    it "should retrieve timestamp" do
      assert @date_entity_1.timestamp.respond_to?(:integer?)
      assert @date_entity_1.timestamp.integer?
    end

    it "should tell you when it does not have a parseable date" do
      assert @date_entity_1.string_date?
      assert_equal false, @date_entity_4.string_date?
    end
  end
end
