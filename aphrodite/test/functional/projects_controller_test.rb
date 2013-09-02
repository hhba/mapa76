require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  context "Display information about a single project" do
    setup do
      @user = FactoryGirl.create :user
      @document_1 = FactoryGirl.create :document, :public
      @document_2 = FactoryGirl.create :document, :public
      @project = FactoryGirl.create :project, :user_ids => [@user.id]

      sign_in @user
    end

    should "Should list project's name" do
      get :show, :id => @project.id
      assert_response :success
      assert_template :show
      assert_not_nil assigns(:project)
    end

    should "Add a document to a project" do
      assert_difference '@project.documents.length' do
        post :add_document, id: @project.id, document_id: @document_2.id
        @project.reload
      end
    end

    should "Remove a document from a project" do
      @project.documents << @document_1
      assert_difference '@project.documents.length', -1 do
        delete :remove_document, id: @project.id, document_id: @document_1.id
        @project.reload
      end
    end
  end

  context "Add documents" do
    setup do
      @user_1 = FactoryGirl.create :user
      @user_2 = FactoryGirl.create :user
      @project_1 = FactoryGirl.create :project, :user_ids => [@user_1.id]
      @project_2 = FactoryGirl.create :project, :user_ids => [@user_1.id]

      @private_doc_user_1 = FactoryGirl.create :document, :private, user: @user_1
      @private_doc_user_2 = FactoryGirl.create :document, :private, user: @user_2
      @private_doc_added_to_other_project = FactoryGirl.create :document, :private
      @project_2.documents << @private_doc_added_to_other_project

      @public_doc = FactoryGirl.create :document, :public
      @public_doc_already_added = FactoryGirl.create :document, :public
      @project_1.documents << @public_doc_already_added

      sign_in @user_1

      get :add_documents, id: @project_1.id
      @own_documents = assigns :own_documents
      @public_documents = assigns :public_documents
      @private_documents = assigns :private_documents
    end

    should "display public and user_1 private docuements" do
      assert @private_documents.include?(@private_doc_user_1), "private documents is not including private document"
      assert @public_documents.include?(@public_doc), "public documents does not include public document"
      assert @own_documents.include?(@public_doc_already_added)
    end

    should "not display private document for another user" do
      assert !@private_documents.include?(@private_doc_user_2)
      assert !@own_documents.include?(@private_doc_added_to_other_project)
    end

    should "not display already added documents" do
      assert !@public_documents.include?(@public_doc_already_added)
      assert !@private_documents.include?(@public_doc_already_added)
    end
  end
end
