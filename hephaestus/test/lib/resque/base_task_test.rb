require 'test_helper'


class NextTask < BaseTask
  @queue = 'next_task'

  def self.perform; end
end

class TestTask < BaseTask
  @queue = 'test_task'
  @next_task = 'next_task'

  def initialize(input)
  end

  def call
    @output = {
      'data' => 'data',
      'metadata' => 'metadata'
    }
  end
end

describe BaseTask do
  it 'returns current task parameterized' do
    test_task = TestTask.new({})
    test_task.current_task.must_equal 'test_task'
  end

  it 'parses JSON input' do
    data = {}.to_json

    JSON.expects(:parse)
    TestTask.any_instance.expects(:call)
    TestTask.perform(data)
  end

  it 'schedules next task' do
    Resque.expects(:enqueue)

    TestTask.perform({}.to_json)
  end

  it 'finish if no `next_task` defined' do
    Resque.expects(:enqueue).never
    NextTask.perform()
  end
end
