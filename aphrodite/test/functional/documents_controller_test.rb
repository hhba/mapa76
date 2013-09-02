require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  context "Public documents" do
    #setup do
      #Document.create_search_index
      #@public_document = create :document, :public, title: "public"
      #@private_document = create :document, title: "private"
      #Document.search_index.refresh
    #end

    #teardown do
      #Document.delete_search_index
    #end

    should "List public documents"
    #should "List public documents" do
      #get :index
      #assert_response :success
      #assert_select "h5", "public"
      #assert_select "tr[data-id=#{@public_document.id}]"
    #end
    
    should "not display private documentos"
    #should "not display private documentos" do
      #get :index
      #assert_response :success
      #assert_select "tr[data-id=#{@private_document.id}]", false
    #end
  end

  context "Documents list and show" do
    setup do
      @user = create :user
      name_entity = create :name_entity
      name_entity_1 = create :name_entity
      date_entity = create :date_entity
      where_entity = create :where_entity
      action_entity = create :action_entity, document: @document
      @document = create :document, :public
      @register = create :fact_register, {
        document: @document,
        person_ids: [name_entity.id],
        action_ids: [action_entity.id],
        complement_person_ids: [name_entity_1.id],
        date_id: date_entity.id,
        place_id: where_entity.id
      }
      sign_in @user
    end

    should "Should list document's name" do
      get :index
      assert_response :success
      assert_template :index
      # assert_not_nil assigns(:documents)
      # assert_select 'td div.title', @document.title
    end

    should "Show one document" do
      get :show, id: @document.id
      assert_response :success
      assert_template :show
      assert_not_nil assigns(:document)
      assert_select 'h1.title', @document.title
    end

    should "Import a new document" do
      get :new
      assert_response :success
      assert_template :new
      assert_select 'h1', "Importar documento"
    end

    should "create a new document and upload file" do
      Tempfile.open("doc.txt") do |fd|
        fd.write("document content")
        fd.close

        document = build :document
        file = Rack::Test::UploadedFile.new(fd.path, "text/plain")

        assert_difference("Document.count") do
          post :create, document: { title: @document.title, file: file }
        end

        # FIXME should save errors somewhere, flash?
        #assert flash[:error].empty?

        assert_redirected_to documents_path
        # FIXME should be the document profile page:
        #assert_redirected_to document_path(assigns(:document))

        created = Document.where(title: @document.title).last
        assert_equal "document content", created.file.data
      end
    end

    should "Retrieve a JSON with the statuses" do
      @document.update_attribute :percentage, 100
      get :status, :format => :json
      status = JSON.parse(@response.body).last

      assert_response :success
      assert_equal @document.title, status['title']
      assert_equal 100, status['percentage']
    end

    should "Retrieve a JSON with the context" do
      get :context, :format => :json, :id => @document.id
      status = JSON.parse(@response.body)

      assert_response :success
      assert_equal @document.title, status["title"]
      assert_instance_of Array, status["registers"]
    end

    should "Show comb page" do
      get :comb, :id => @document.id

      assert_response :success
    end

    should "download documents original file" do
      get :download, :id => @document.id

      assert_response :success
      assert_equal "empty content", @response.body
    end
  end
end
