class projects.Timeliner
  constructor: (elementId)->
    @elementId = elementId
    @bind()
    @initialize()

  bind: ->
    @container = $("##{@elementId}")
    @projectId = @container.data("project-id")
    @timeliner = new links.Timeline document.getElementById(@elementId)

  initialize: ->
    @getData()

  render: ->
    @timeliner.draw @parsedDates, @options()

  options: ->
    {
      width: "100%"
      style: "box"
    }

  process: (response) ->
    @name = response.name
    @description = response.description
    @parsedDates = _.flatten @processDocuments(response.documents)
    @render()

  processDocuments: (documents) ->
    _.map documents, (document) =>
      @processDocument(document.document)

  processDocument: (document) ->
    _.map document.dates_found, (date) =>
      {
        group:   document.title
        start:   @processDate(date.dates_found)
        link:    date.dates_found.link
        content: date.dates_found.text
      }

  processDate: (date) ->
    new Date(
      parseInt(date.date.year, 10),
      parseInt(date.date.month, 10) - 1,
      parseInt(date.date.day, 10)
    )

  getData: ->
    $.get "/api/v1/projects/#{@projectId}/timeline", null, ((response) =>
      @process(response)
    ), "json"
