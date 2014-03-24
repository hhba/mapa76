var window._ga = {
  selectDocument: function(documentId){
    ga.send('send', 'event', 'selectDocument', 'document', documentId);
  },
  viewDocument: function(documentId){
    ga.send('send', 'event', 'openDocument', 'documentsView', documentId);
  },
  downloadDocument: function(documentId){
    ga.send('send', 'event', 'downloadDocument', 'documentsView', documentId);
  },
  checkEntity: function(documentId, entity){
    ga.send('send', 'event', 'checkEntity', 'documentsView', entity);
  },
  checkOrganizations: function(documentId){
    ga.send('send', 'event', 'checkOrganizations', 'documentsView', documentId);
  },
  checkPlaces: function(documentId){
    ga.send('send', 'event', 'checkOrganizations', 'documentsView', documentId);
  },
  checkDates: function(documentId){
    ga.send('send', 'event', 'checkDates', 'documentsView', documentId);
  },
  exportCSV: function(documentId){
    ga.send('send', 'event', 'exportCSV', 'documentView', documentId);
  },
  clickEntity: function(entityId){
    ga.send('send', 'event', 'clickEntity', 'documentView', entityId);
  }
}
