class projects.Project
  constructor: (projectId) ->
    @projectId = projectId
    @initialize()

  initialize: ->
    @bind()
    @getDocumentData()

  bind: ->
    self = @
    @container = $("#documents")
    @template = _.template $("#documentsList").html()
    @container.on "click", "i.remove", (event) ->
      event.preventDefault()
      self.handleClick(@)

  render: ->
    @container.html(
      @template(
        projectId: @projectId
        documents: @documentsJSON
      )
    )

  getDocumentData: ->
    $.get "/projects/#{@projectId}", null, ((response) =>
      @documentsJSON = response
      @render()
    ), 'json'

  handleClick: (element) ->
    documentId = $(element).data "document-id"
    $.post("/projects/#{@projectId}/remove_document",
      document_id: documentId
      _method: "delete",
      null,
      'json'
    )
    $(element).parents("li").remove()
