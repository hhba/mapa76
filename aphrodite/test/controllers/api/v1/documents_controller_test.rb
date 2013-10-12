require 'test_helper'

describe Api::V1::DocumentsController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }

  before do
    user.documents << document
    sign_in user
  end

  describe '#update' do
    it '' do
      put :update, id: document.id, document: {title: 'new title'}
      document.reload
      document.title.must_equal 'new title'
    end
  end
end
