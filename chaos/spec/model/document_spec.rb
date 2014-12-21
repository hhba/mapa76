require "spec_helper"

describe Document do
  before do
    @document = FactoryGirl.create :document, percentage: 100
  end

  describe '#flagger' do
    it '' do
      user = mock(id: Moped::BSON::ObjectId.new)
      User.expects(:find).returns(user)
      @document.update_attribute :flagger_id, user.id
      @document.reload

      @document.flagger.must_equal user
    end
  end

  describe "after_save" do
    it "should enqueue process bootstrap task" do
      document = build :document
      Resque.expects(:enqueue).with(SchedulerTask, {metadata: {document_id: document.id, url: nil, document_type: 'file_document'}}.to_json)
      assert document.save
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

  describe '#process!' do
    it 'resets the status field and the call resque' do
      document = FactoryGirl.create :document, status: 'process-end'
      Resque.expects(:enqueue).with(SchedulerTask,  {metadata: {document_id: document.id, url: nil, document_type: 'file_document'}}.to_json)
      document.process!

      document.status.must_be :==, ""
      document.percentage.must_be :==, 0
    end
  end

  describe '#mark_as_failed' do
    it 'change status' do
      Document.stubs(:find).returns(@document)

      Document.mark_as_failed('id', 'Error')
      @document.reload
      @document.status.must_equal "FAILED"
      @document.percentage.must_equal -1
      @document.status_msg.must_equal 'Error'
    end

    it 'returns false when document not found' do
      Document.mark_as_failed('id', 'Error').must_equal false
    end
  end
end
