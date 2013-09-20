require 'test_helper'

describe SearcherService do
  let(:user) { FactoryGirl.build :user }

  it 'stores the query' do
    SearcherService.any_instance.stubs(:call).returns([])
    Search.expects(:create)

    searcher = SearcherService.new(user)
    searcher.where({q: 'term'})
  end
end
