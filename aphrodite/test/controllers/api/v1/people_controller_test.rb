require 'test_helper'

describe Api::V1::PeopleController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }
  let(:person) { FactoryGirl.create :person }

  context 'signed in' do
    before do
      sign_in user
    end

    describe 'GET #show' do
      it '' do
        user.people << person
        get :show, id: person.id, format: 'json'

        response.status.must_equal 200
        json['name'].must_equal person.name
      end
    end
  end

  context 'not signed in' do
    describe 'GET #show' do
      it 'gets unauthorized' do
        get :show, id: person.id, format: 'json'
        response.status.must_equal 401
      end
    end
  end
end
