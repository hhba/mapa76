# encoding: utf-8
require "test_helper"

describe GlueTask do
  before do
  end

  context 'document with default tasks' do
    it 'has default tasks' do
      task_finder = GlueTask::TaskFinder.new(Object.new)
      task_finder.tasks.must_be_instance_of Array
      task_finder.current_task.must_be :==, "NormalizationTask"
    end
  end

  context "A document can have it's oung tasks" do
    it 'can have it is own tasks' do
      document= MiniTest::Mock.new
      document.expect :tasks, %w(NormalizationTask LayoutAnalysisTask)

      task_finder = GlueTask::TaskFinder.new(document)
      task_finder.tasks.must_be_instance_of Array
      task_finder.tasks.must_be :==, %w(NormalizationTask LayoutAnalysisTask)
    end
  end
end
