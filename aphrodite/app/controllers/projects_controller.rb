class ProjectsController < ApplicationController
  before_filter :authenticate_user!, except: :show

  def index
    @projects = current_user.projects
  end

  def show
    @project = Project.where(slug: params[:id]).first
    if @project
      render layout: 'aeolus'
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def new
    @project = Project.new
  end

  def create
    @project = current_user.projects.build params[:project]
    if @project.save
      redirect_to project_path(@project)
    else
      render :new
    end
  end

  def add_documents
    @project = current_user.projects.find params[:id]
    @own_documents = @project.documents
    @public_documents = Document.without(@own_documents).public
    @private_documents = Document.without(@own_documents).private_for(current_user)
  end

  def add_document
    @project = Project.find params[:id]
    render json: @project.add_document_by_id(params[:document_id]).to_json
  end

  def remove_document
    @project = Project.find params[:id]
    render json: @project.remove_document_by_id(params[:document_id]).to_json
  end
end
