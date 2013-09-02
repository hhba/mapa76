class projects.OwnDocumentsList extends projects.DocumentList
  update: (document) ->
    $.post "/projects/#{@projectId}/remove_document",
      document_id: document._id
      _method: "delete"

  messages: ->
    {title: "Documentos del proyecto", tooltip: "Remover"}
