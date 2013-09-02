class projects.OtherDocumentsList extends projects.DocumentList
  update: (document) ->
    $.post "/projects/#{@projectId}/add_document",
      document_id: document._id

  messages: ->
    {title: "Documentos públicos y privados", tooltip: "Agregar"}
