require 'test_helper'

describe JobsService do
  let(:jobs) do
    {
      "queue"=>"extraction_task",
      "run_at"=>"2013-09-25T18:06:58Z",
      "payload"=>{
        "class"=>"ExtractionTask",
        "args"=>["524326399f9d515a54000009"]
      }
    }
  end

  describe '#working_on?' do
    context 'there is no job working' do
      it 'returns false' do
        Resque.stubs(working: [])
        document = FactoryGirl.create :document

        JobsSerivice.working_on?(document).must_equal false
      end
    end

    context 'there is a job working on a different document' do
      it 'returns false' do
        Resque.stubs(working: [jobs])
        document = FactoryGirl.create :document

        JobsSerivice.working_on?(document).must_equal false
      end
    end

    context 'job working on current document' do
      it 'returns true' do
        Resque.stubs(working: [jobs])
        document = stub(id: "524326399f9d515a54000009")

        JobsSerivice.working_on?(document).must_equal true
      end
    end
  end
end
