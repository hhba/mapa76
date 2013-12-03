/*
 * Backbone Global Overrides
 *
 */

// Override Backbone.sync to send custom HTTP Headers

var originalSync = Backbone.sync;

Backbone.sync = function(method, model, options) {
  options = options || {};

  if (!options.headers) {
    options.headers = {};
  }

  if (options.xDocumentIds){
    options.headers[aeolus.headers.xDocumentIds] = options.xDocumentIds.join(",");
  }

  if (options.xPages){
    options.headers[aeolus.headers.xPages] = options.xPages.join(",");
  }

  return originalSync(method, model, options);
};
