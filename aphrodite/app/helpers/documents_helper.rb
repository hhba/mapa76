module DocumentsHelper
  def thumbnail_url(document)
    if document.thumbnail_file
      "#{Mapa76::Application.config.thumbnails_path}/#{document.id}.png"
    else
      asset_path("thumbnail_placeholder.png")
    end
  end

  def status(document)
    {
      id:              document._id,
      title:           document.title,
      category:        document.category,
      percentage:      document.percentage,
      readable:        document.readable?,
      geocoded:        document.geocoded?,
      exportable:      document.exportable?,
      completed:       document.completed?,
      generation_time: document.id.generation_time.strftime("%d/%m/%y"),
      thumbnail:       thumbnail_url(document),
      failed:          document.failed?,
    }
  end

  def documents_page?
    current_page?(documents_path) and !params.has_key?(:mine) and !params.has_key?(:project_id)
  end

  def my_documents_page?
    params.has_key?(:mine)
  end

  def new_document_page?
    current_page? new_document_path
  end

  def active_on_documents_page
    documents_page? ? "active" : nil
  end

  def active_on_my_documents_page
    my_documents_page? ? "active" : nil
  end

  def active_on_new_document_page
    new_document_page? ? "active" : nil
  end

  def search_page?
    controller_name == "documents" && params.has_key?(:q)
  end

  def project_page?
    controller_name == "documents" && params.has_key?(:project_id)
  end

  def progress_classes(document)
    if document.completed?
      "progress progress-striped active hide"
    else
      "progress progress-striped active"
    end
  end
end
