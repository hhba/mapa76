module ApplicationHelper
  def ga_page(project, document)
    if @document
      @document.title
    elsif @project
      @project.name
    end
  end

  def project_token(project)
    if project
      project.project_token
    else
      current_user.access_token
    end
  end

  def current_project
    require 'ostruct'
    project = OpenStruct.new
    project.name = "ESMA"
    project
  end

  def current_document
    require 'ostruct'
    document = OpenStruct.new
    document.name = "Fundamentos"
    document
  end

  def single_project_view?
    params.has_key? :project_id
  end

  def day_from(lemma)
    /^\[.{2}\:(\d{1,2})\/(\d{1,2})\/(\d{1,4})/.match(lemma)[1]
  end

  def month_from(lemma)
    /^\[.{2}\:(\d{1,2})\/(\d{1,2})\/(\d{1,4})/.match(lemma)[2]
  end

  def year_from(lemma)
    /^\[.{2}\:(\d{1,2})\/(\d{1,2})\/(\d{1,4})/.match(lemma)[3]
  end

  def named_entity_link(ne)
    "/documents/#{ne.document_id}/comb#"
  end

  def active_on_documents
    controller_name == "documents" ? 'active' : nil
  end

  def active_on_projects
    controller_name == "projects" ? 'active' : nil
  end

  def show_count(documents=nil, results=nil)
    if results.nil?
      link_to t("all_documents") + " (#{@documents.count})", documents_path
    else
      total = 0
      @results.each { |r| total = total + r.count }
      link_to 'Resultados' + " (#{total}/#{@results.count})", documents_path
    end
  end

  def can_delete?(document)
    JobsService.not_working_on?(document)
  end

  def flash_message(name)
    if name == :notice
      'success'
    elsif name == :alert
      'error'
    else
      name
    end
  end

  def data_attributes
    @data_attributes || {}
  end
end
