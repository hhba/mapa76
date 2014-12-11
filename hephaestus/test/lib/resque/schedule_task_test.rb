require 'test_helper'

describe ScheduleTask do
  it 'First task is extraction_text_task' do
    Resque.expects(:enqueue).with(ExtractionTextTask, {})

    scheduler = ScheduleTask.new({})
    scheduler.next_task.must_equal 'extraction_text_task'
    scheduler.call
  end

  it 'Second task is ne_finder_task' do
    input = {
      'metadata' => {
        'current_task' => 'extraction_text_task'
      }
    }
    Resque.expects(:enqueue).with(NeFinderTask, input)

    scheduler = ScheduleTask.new(input)
    scheduler.next_task.must_equal 'ne_finder_task'
    scheduler.call
  end

  it 'returns nil when done' do
    Resque.expects(:enqueue).never
    input = {
      'metadata' => {
        'current_task' => ScheduleTask::DEFAULT_TASKS.last
      }
    }

    scheduler = ScheduleTask.new(input)
    scheduler.next_task.must_be_nil
    scheduler.call
  end
end
