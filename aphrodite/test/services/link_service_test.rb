require 'test_helper'

describe LinkService do
  let(:user) { FactoryGirl.create :user }
  let(:file_url) { 'http://localhost:8000/americanpsico.txt' }

  describe '#filename' do
    it 'gets filename' do
      link_service = LinkService.new(file_url)
      link_service.filename.must_equal 'americanpsico.txt'
    end
  end
end
