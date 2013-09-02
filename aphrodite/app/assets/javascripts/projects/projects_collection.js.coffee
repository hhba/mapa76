class projects.ProjectsCollection
  constructor: (container) ->
    @container = container
    @initialize()

  initialize: ->
    @projectsJSON = @container.data("projects")
    @bind()
    @render()

  bind: ->
    self = @
    @container.on "click", ".nav a", (event) ->
      event.preventDefault()
      self.handleClick(@)
    @template = _.template $("#projectsList").html()

  render: ->
    @container.html(
      @template(
        projects: @projectsJSON
      )
    )

  handleClick: (element)->
    new projects.Project $(element).data("project-id")
