require 'test_helper'

describe DocumentsController do
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

  context "Documents list and show" do
    before do
      @user         = FactoryGirl.create :user
      name_entity   = FactoryGirl.create :name_entity
      name_entity_1 = FactoryGirl.create :name_entity
      date_entity   = FactoryGirl.create :date_entity
      where_entity  = FactoryGirl.create :where_entity
      action_entity = FactoryGirl.create :action_entity, document: @document
      @document     = FactoryGirl.create :document, :public
      @user.documents << @document
      @register     = FactoryGirl.create :fact_register, {
        document: @document,
        person_ids: [name_entity.id],
        action_ids: [action_entity.id],
        complement_person_ids: [name_entity_1.id],
        date_id: date_entity.id,
        place_id: where_entity.id
      }
      sign_in @user
    end

    it "it list document's name" do
      get :index
      assert_response :success
      assert_template :index
      # assert_not_nil assigns(:documents)
      # assert_select 'td div.title', @document.title
    end

    it "Show one document" do
      get :show, id: @document.id
      assert_response :success
      assert_template :show
      assert_not_nil assigns(:document)
      assert_select 'h1.title', @document.title
    end

    it "Import a new document" do
      get :new
      assert_response :success
      assert_template :new
      assert_select 'h1', "Importar documento"
    end

    it "create a new document and upload file" do
      Tempfile.open("doc.txt") do |fd|
        fd.write("document content")
        fd.close

        document = build :document
        file = Rack::Test::UploadedFile.new(fd.path, "text/plain")

        assert_difference("Document.count") do
          post :create, document: { title: @document.title, file: file }
        end

        # FIXME it save errors somewhere, flash?
        #assert flash[:error].empty?

        assert_redirected_to documents_path
        # FIXME it be the document profile page:
        #assert_redirected_to document_path(assigns(:document))

        created = Document.where(title: @document.title).last
        assert_equal "document content", created.file.data
      end
    end

    it 'add the new document to current_user' do
      Tempfile.open("doc.txt") do |fd|
        fd.write("document content")
        fd.close

        document = build :document
        file = Rack::Test::UploadedFile.new(fd.path, "text/plain")

        post :create, document: { title: @document.title, file: file }
        assert_equal @user.documents.length, 1
      end
    end

    it "Retrieve a JSON with the context" do
      get :context, :format => :json, :id => @document.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal @document.title, status["title"]
      assert_instance_of Array, status["registers"]
    end

    it "Show comb page" do
      get :comb, :id => @document.id

      assert_response :success
    end

    it "download documents original file" do
      get :download, :id => @document.id

      assert_response :success
      assert_equal "empty content", @response.body
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
