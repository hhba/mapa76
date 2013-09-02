module ApplicationHelper
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
end

