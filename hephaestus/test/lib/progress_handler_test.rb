require 'test_helper'

describe ProgressHandler do
  context 'document has not been analized' do
    let(:document) { stub(status: '', tasks: []) }

    before do
      TaskFinder.any_instance.stubs(:tasks_count).returns(4)
      @progress_handler = ProgressHandler.new(document)
    end

    describe '#starting_at' do
      it 'starts on 0' do
        @progress_handler.starting_at.must_equal 0
      end
    end

    describe '#ending_at' do
      it 'ends on 25' do
        @progress_handler.ending_at.must_equal 20.0
      end
    end
  end

  context 'document has one task completed' do
    let(:document) { stub(status: '', tasks: []) }

    before do
      TaskFinder.any_instance.stubs(:count).returns(4)
      TaskFinder.any_instance.stubs(:index).returns(1)
      @progress_handler = ProgressHandler.new(document)
    end

    describe '#starting_at' do
      it 'starts on 25' do
        @progress_handler.starting_at.must_equal 25
      end
    end

    describe '#ending_at' do
      it 'ends on 50' do
        @progress_handler.ending_at.must_equal 50
      end
    end

    describe '#increment' do
      it 'updates the document status' do
        document.expects(:update_attribute).with(:percentage, 25.25)
        @progress_handler.increment
      end
    end

    describe '#increment_to' do
      it 'hardcode increment' do
        document.expects(:update_attribute).with(:percentage, 30)
        @progress_handler.increment_to(30)
      end
    end
  end
end
