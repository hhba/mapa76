require "test_helper"


describe SchedulerTask do
  let(:first_input) { {'metadata' => {'current_task' => nil }} }
  let(:middle_task) { {'metadata' => {'current_task' => 'task_1' }} }
  let(:last_task) { {'metadata' => {'current_task' => 'task_3' }} }
  let(:change_flux) { {'metadata' => {'current_task' => 'task_3', 'next_task' => 'other_task' }} }
  let(:finish_early) { {'metadata' => {'current_task' => 'task_3', 'next_task' => false }} }

  before do
    class Task1
    end
    SchedulerTask.any_instance.stubs(:tasks).returns(%W(task_1 task_2 task_3))
  end

  describe "#call" do
    it 'schedules the following task' do
      SchedulerTask.any_instance.stubs(:update_document_status).returns(nil)
      Resque.expects(:enqueue).with(Task1, first_input.to_json)
      scheduler = SchedulerTask.new(first_input)
      scheduler.call
    end

    it 'does not schedules a task on last' do
      SchedulerTask.any_instance.stubs(:close_document).returns(nil)
      Resque.expects(:enqueue).never
      scheduler = SchedulerTask.new(last_task)
      scheduler.call
    end
  end

  describe "#next_task?" do
    it 'returns true when first task' do
      scheduler = SchedulerTask.new(first_input)
      scheduler.next_task?.must_equal true
    end

    it 'returns true when there is a default next_task' do
      scheduler = SchedulerTask.new(middle_task)
      scheduler.next_task?.must_equal true
    end

    it 'returns false on last_task' do
      scheduler = SchedulerTask.new(last_task)
      scheduler.next_task?.must_equal false
    end

    it 'returns false on finish_early' do
      scheduler = SchedulerTask.new(finish_early)
      scheduler.next_task?.must_equal false
    end

    it 'returns true on change the flux' do
      scheduler = SchedulerTask.new(change_flux)
      scheduler.next_task?.must_equal true
    end
  end

  describe "#next_task" do
    it 'returns task_1 on first task' do
      scheduler = SchedulerTask.new(first_input)
      scheduler.next_task.must_equal 'task_1'
    end

    it 'returns task_2 on second task' do
      scheduler = SchedulerTask.new(middle_task)
      scheduler.next_task.must_equal 'task_2'
    end

    it 'returns other_task on flux change' do
      scheduler = SchedulerTask.new(change_flux)
      scheduler.next_task.must_equal 'other_task'
    end
  end

  describe "#next_task_class" do
    it 'returns a valid class' do
      scheduler = SchedulerTask.new(first_input)
      scheduler.next_task_class.must_equal Task1
    end
  end
end
