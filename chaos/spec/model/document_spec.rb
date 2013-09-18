require "spec_helper"

describe Document do
  before do
    @document = FactoryGirl.create :document, percentage: 100
  end

  describe "after_save" do
    it "should enqueue process bootstrap task" do
      document = build :document
      Resque.expects(:enqueue).with(DocumentProcessBootstrapTask, document.id)
      assert document.save
    end
  end

  describe "after_destroy" do
    it "should destroy #file and #thumbnail_file" do
      @document.file = StringIO.new("document")
      @document.thumbnail_file = StringIO.new("thumbnail")

      @document.destroy

      assert_raises(Mongoid::Errors::DocumentNotFound) do
        assert @document.file
      end
      assert_raises(Mongoid::Errors::DocumentNotFound) do
        assert @document.thumbnail_file
      end
    end
  end

  describe "validation" do
    it "should have a `file_id` defined" do
      @document.file_id = nil
      refute @document.valid?
    end

    it "should have an `original_filename` defined" do
      @document.original_filename = nil
      refute @document.valid?
    end
  end

  describe "#file=" do
    it "should upload the given file to GridFS and set #file_id" do
      @document.file_id = nil
      @document.file = StringIO.new("a different file\n")
      refute @document.file_id.nil?
      assert_equal "a different file\n", @document.file.data
    end
  end

  describe "#file" do
    it "should return nil if #file_id is nil" do
      @document.file_id = nil
      assert @document.file.nil?
    end

    it "should return the file from GridFS" do
      assert_equal @document.file.id, @document.file_id
      assert_equal "empty content", @document.file.data
    end
  end

  describe "#thumbnail_file=" do
    it "should upload the given thumbnail file to GridFS and set #thumbnail_file_id" do
      @document.thumbnail_file_id = nil
      @document.thumbnail_file = StringIO.new("a different file\n")
      refute @document.thumbnail_file_id.nil?
      assert_equal "a different file\n", @document.thumbnail_file.data
    end
  end

  describe "#thumbnail_file" do
    it "should return nil if #thumbnail_file_id is nil" do
      @document.thumbnail_file_id = nil
      assert @document.thumbnail_file.nil?
    end

    it "should return the thumbnail file from GridFS" do
      @document.thumbnail_file = StringIO.new("thumbnail")
      assert_equal @document.thumbnail_file.id, @document.thumbnail_file_id
      assert_equal "thumbnail", @document.thumbnail_file.data
    end
  end

  describe "ElasticSearch indexing" do
    before do
      # Wait for ES to index document...
      sleep 1
    end

    it "should add to index when creating new document" do
      search = Document.tire.search("*")
      assert_equal 1, search.count
      assert_equal @document.id.to_s, search.results.first.id

      search = Document.tire.search(@document.title)
      assert_equal 1, search.count
      assert_equal @document.id.to_s, search.results.first.id
    end

    it "should update index if document is modified" do
      @document.update_attributes(title: "New Title")
      sleep 1

      search = Document.tire.search(@document.title)
      assert_equal 1, search.count
      assert_equal @document.id.to_s, search.results.first.id
    end

    it "should update index if document is modified" do
      @document.update_attributes(title: "New Title")
      sleep 2

      search = Document.tire.search(@document.title)
      assert_equal 1, search.count
      assert_equal @document.id.to_s, search.results.first.id
    end

    it "should delete from index if document is destroyed" do
      @document.destroy
      sleep 2

      search = Document.tire.search("*")
      assert search.count.zero?
    end

    it "should update index if a page is modified" do
      text_line = TextLine.new(text: @document.processed_text)
      @document.pages << Page.new(num: 1, text_lines: [text_line])

      @document.save
      sleep 2

      search = Document.tire.search("empty")
      assert_equal 1, search.count
      assert_equal @document.id.to_s, search.results.first.id
    end
  end

  describe '#process!' do
    it 'resets the status field and the call resque' do
      document = FactoryGirl.create :document, status: 'process-end'
      Resque.expects(:enqueue).with(DocumentProcessBootstrapTask, document.id)
      document.process!

      document.status.must_be :==, ""
      document.percentage.must_be :==, 0
    end
  end

  describe '#destroy' do
    it 'does not destroy a document if process is incomplete' do
      document = FactoryGirl.create :document, percentage: 90
      document.destroy
      document.destroyed?.must_equal false
    end
  end
end
