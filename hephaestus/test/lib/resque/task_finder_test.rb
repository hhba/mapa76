require 'test_helper'

describe TaskFinder do
  let(:document) {MiniTest::Mock.new}
  let(:task_finder) { TaskFinder.new(document) }

  before do
    document.expect :tasks, []
    document.expect :status, ''
  end

  describe '#tasks_count' do
    it 'count the tasks' do
      task_finder.stubs(:tasks).returns %w(1 2 3)
      task_finder.count.must_equal 3
    end
  end

  describe '#task_index' do
    it 'retrieves task index (0)' do
      task_finder.index.must_equal 0
    end

    it 'retrieves task index (1)' do
      document.expect :status, 'layout_analysis_task-start'
      task_finder.index.must_equal 1
    end
  end

  context 'document does not specifies tasks' do
    it 'works' do
      task_finder.tasks.must_be_instance_of Array
      task_finder.current_task.must_equal 'normalization_task'
    end

    context 'document has finished first task' do
      it 'retrieves second task' do
        document.expect :status, 'normalization_task-end'
        task_finder.next_task.must_equal 'layout_analysis_task'
      end

      it 'tells that has finished' do
        document.expect :status, 'normalization_task-end'
        assert task_finder.current_task_ended?
      end
    end
  end

  context 'document has not finished current_task' do
    it 'tells that it has not finished' do
      document.expect :status, 'normalization_task-start'
      refute task_finder.current_task_ended?
    end

    it 'does not move to next task' do
      document.expect :status, 'normalization_task-start'
      task_finder.next_task.must_equal 'normalization_task'
    end
  end

  context 'documents can have its own tasks' do
    it 'has own tasks' do
      document.expect :tasks, %w(normalization_task layout_analysis_task)
      task_finder = TaskFinder.new(document)
      task_finder.tasks.must_equal %w(normalization_task layout_analysis_task)
    end
  end

  describe 'Fully functional test' do
    before do
      document.expect :tasks, %w(start_task middle_task final_task)
    end

    context 'document with three custom tasks' do
      it 'follows the flow' do
        task_finder.current_task.must_equal 'start_task'

        document.expect :status, 'start_task-start'
        task_finder.current_task.must_equal 'start_task'
        task_finder.next_task.must_equal 'start_task'

        document.expect :status, 'start_task-end'
        task_finder.current_task.must_equal 'start_task'
        task_finder.next_task.must_equal 'middle_task'

        document.expect :status, 'middle_task-start'
        task_finder.current_task.must_equal 'middle_task'
        task_finder.next_task.must_equal 'middle_task'

        document.expect :status, 'middle_task-end'
        task_finder.current_task.must_equal 'middle_task'
        task_finder.next_task.must_equal 'final_task'

        document.expect :status, 'final_task-start'
        task_finder.current_task.must_equal 'final_task'
        task_finder.next_task.must_equal 'final_task'

        document.expect :status, 'final_task-end'
        task_finder.current_task.must_equal 'final_task'
        task_finder.next_task.must_be_nil
      end
    end
  end
end
