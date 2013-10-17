require 'test_helper'

describe DocumentsController do
  describe 'GET #index' do
    context 'Sorting' do
      let(:user){ FactoryGirl.create :user }
      let(:relation) { mock() }

      before do
        # Don't render views on this tests
        @controller.expects(:render)

        sign_in user
      end

      it 'sorts by created_at desc by default' do
        relation.expects(:order_by).with("created_at desc")
        Document.expects(:where).returns(relation)

        get :index
      end

      it 'sorts by created_at asc' do
        relation.expects(:order_by).with("created_at asc")
        Document.expects(:where).returns(relation)

        get :index, direction: 'asc'
      end

      it 'sorts by title desc' do
        relation.expects(:order_by).with("title desc")
        Document.expects(:where).returns(relation)

        get :index, sort: 'title'
      end

      it 'handles wrong parameters' do
        relation.expects(:order_by).with("created_at desc")
        Document.expects(:where).returns(relation)

        get :index, sort: 'something', direct: 'wrong'
      end
    end

    context 'List documents' do
      let(:user) { FactoryGirl.create :user }
      let(:document) { FactoryGirl.create :document }

      before do
        user.documents << document
        sign_in user
      end

      it "it list document's name" do
        get :index
        assert_response :success
        assert_template :index
      end
    end
  end

  describe 'POST #create' do
    context 'no user signed in' do
      it 'does not creates a new document' do
        post :create, document: { title: 'title' }
        response.status.must_equal 302
      end
    end
  end

  context 'User signed in' do
    let(:user) { FactoryGirl.create :user }
    let(:document) { FactoryGirl.create :document }

    before do
      sign_in user
    end

    describe 'POST #link' do
      context 'url as an argument' do
        it '' do
          link = mock(call: true)
          LinkService.expects(:new).returns(link)

          post :link, document: { link: 'http://example.org/file.txt' }
          response.status.must_equal 302
        end
      end

      context 'wrong arguments' do
        it 'sends an error message'
      end
    end

    describe 'POST #flag' do
      it '' do
        flagger_service = mock
        FlaggerService.expects(:new).with(user, document).returns(flagger_service)
        flagger_service.expects(:call)
        post :flag, id: document.id

        response.status.must_equal 302
        assert_redirected_to documents_path
      end
    end

    describe 'GET #context' do
      it "Retrieve a JSON with the context" do
        get :context, :format => :json, :id => document.id
        status = JSON.parse(@response.body)

        assert_response :success
        assert_equal document.title, status["title"]
        assert_instance_of Array, status["registers"]
      end
    end

    describe 'GET #show' do
      it "Show one document" do
        get :show, id: document.id
        assert_response :success
        assert_template :show
        assert_not_nil assigns(:document)
        assert_select 'h1.title', document.title
      end
    end

    describe 'GET #new' do
      it "Import a new document" do
        get :new
        assert_response :success
        assert_template :new
        assert_select 'h3', "Importar documento"
      end
    end

    describe 'GET #download' do
      it "download documents original file" do
        get :download, :id => document.id

        assert_response :success
        assert_equal "empty content", @response.body
      end
    end

    describe 'GET #comb' do
      it "Show comb page" do
        get :comb, :id => document.id

        assert_response :success
      end
    end

    describe 'POST #create' do
      it 'creates a new document and assigns it to current user' do
        Tempfile.open("doc.txt") do |fd|
          fd.write("document content")
          fd.close

          document = build :document
          file = Rack::Test::UploadedFile.new(fd.path, "text/plain")

          post :create, document: {files: [file]}
          assert_equal user.documents.length, 1
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    before do
      user = FactoryGirl.create :user
      @document = FactoryGirl.create :document
      user.documents << @document
      sign_in user
    end

    context 'document can be destroyed' do
      it 'destoys the document' do
        JobsService.stubs(:'not_working_on?' => true)
        initial_count = Document.count
        delete :destroy, id: @document.id
        final_count = Document.count

        assert final_count < initial_count
        assert_response :redirect
      end
    end

    context 'document can NOT be destroyed' do
      it 'does not destroys the document' do
        JobsService.stubs(:'not_working_on?' => false)
        initial_count = Document.count
        delete :destroy, id: @document.id
        final_count = Document.count

        assert final_count == initial_count
        assert_response :redirect
      end
    end
  end
end
