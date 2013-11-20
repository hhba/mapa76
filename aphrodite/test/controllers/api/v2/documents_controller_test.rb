require 'test_helper'

describe Api::V2::DocumentsController do
  let(:user) { FactoryGirl.create :user }
  let(:document) { FactoryGirl.create :document }

  context 'Authorized' do
    before do
      user.documents << document
      authenticate_api(user.access_token)
    end

    describe 'GET #search' do
      it 'returns results' do
        result = stub(
          id: document.id,
          title: document.title,
          original_filename: '',
          highlight: [])
        SearcherService.any_instance.stubs(:where).returns([[result]])

        get :search, q: 'text', format: 'json'
        json.first['title'] = document.title
        response.status = 200
      end
    end

    describe 'POST #create' do
      it 'creates a new document' do
        Tempfile.open("doc.txt") do |fd|
          fd.write("document content")
          fd.close

          document = build :document
          file = Rack::Test::UploadedFile.new(fd.path, "text/plain")

          post :create, document: {files: [file]}
          user.documents.length.must_equal 2
          response.status.must_equal 201
        end
      end
    end

    describe 'POST #flag' do
      it 'flags a document' do
        flagger_service = mock
        FlaggerService.expects(:new).with(user, document).returns(flagger_service)
        flagger_service.expects(:call)

        post :flag, id: document.id

        response.status.must_equal 204
      end
    end

    describe 'GET #index' do
      it 'returns a list of documents' do
        get :index, format: 'json'
        response.status.must_equal 200
        json.first['title'].must_equal document.title
      end
    end

    describe 'GET #show' do
      it 'returns info about the document' do
        get :show, id: document.id, format: 'json'
        json['id'].must_equal document.id.to_s
        response.status.must_equal 200
      end
    end

    describe 'GET #status' do
      context 'document has finished' do
        it 'returns an empty array' do
          document.update_attribute :percentage, 100.0
          get :status, format: 'json'
          json.must_equal []
          response.status.must_equal 200
        end
      end

      context 'document in process' do
        it 'returns an array with id and percentage' do
          get :status, format: 'json'
          json.first['id'].must_equal document.id.to_s
          json.first['percentage'].must_equal 0.0
        end
      end
    end

    describe 'DELETE #destroy' do
      context 'multiple documents' do
        it 'destroys multiple documents' do
          request.env['X-Document-Ids'] = document.id.to_s

          delete :destroy, format: 'json'
          response.status.must_equal 204
        end
      end

      context 'document can be destroyed' do
        it 'destroys the document' do
          JobsService.stubs(:'not_working_on?' => true)
          initial_count = Document.count
          delete :destroy, id: document.id, format: 'json'
          final_count = Document.count

          assert final_count < initial_count
          assert_response :no_content
        end
      end

      context 'document can NOT be destroyed' do
        it 'does not destroys the document' do
          JobsService.stubs(:'not_working_on?' => false)
          initial_count = Document.count
          delete :destroy, id: document.id
          final_count = Document.count

          assert final_count == initial_count
          assert_response :bad_request
        end
      end
    end
  end

  context 'Unauthorized' do
    describe 'GET #index' do
      it 'returns 401' do
        get :index, format: 'json'
        response.status.must_equal 401
      end
    end
  end
end
