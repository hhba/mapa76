class projects.DocumentList
  constructor: (projectId, documents, container)->
    @documents = documents || []
    @container = container
    @projectId = projectId
    @initialize()

  initialize: ->
    @bind()
    @render()

  bind: ->
    self = @
    @template = _.template $("#documentList").html()
    @container.on "click", "i", (event) ->
      event.preventDefault()
      self.handleClick(@)

  render: ->
    @container.html(
      @template(
        messages: @messages()
        documents: @documents
      )
    )

  handleClick: (element) ->
    document = @findDocumentById($(element).hide().data("id"))
    @removeDocument(document)
    @opposite.addDocument(document)
    @update(document)

  addDocument: (document) ->
    @documents.push document
    @render()

  removeDocument: (document) ->
    @removeDocumentById(document._id)
    @render()

  removeDocumentById: (id) ->
    @documents = _.filter @documents, (document)->
      document._id isnt id

  findDocumentById: (id) ->
    _.find @documents, (document) ->
      document._id is id
