var DocumentsCollection = Backbone.Collection.extend({
  model: Document,
  url: '/api/v1/documents'
});
