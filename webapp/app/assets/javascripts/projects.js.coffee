$ ->
  if $(".add_documents").length
    addDocumentsElement = $(".add_documents")

    otherDocumentsList = new projects.OtherDocumentsList(
      addDocumentsElement.data("project-id")
      addDocumentsElement.data("other-documents")
      $(".notadded")
    )

    ownDocumentsList = new projects.OwnDocumentsList(
      addDocumentsElement.data("project-id")
      addDocumentsElement.data("own-documents")
      $(".added")
    )

    otherDocumentsList.opposite = ownDocumentsList
    ownDocumentsList.opposite = otherDocumentsList

  if $("#projects").length
    projectsCollection = new projects.ProjectsCollection $("#projects")
