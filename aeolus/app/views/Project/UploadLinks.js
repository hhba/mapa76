var
  template = require('./templates/uploadLinks.tpl'),
  Link = require("../../models/Link");

module.exports = Backbone.Marionette.ItemView.extend({
  template: template,

  events: {
    'click .submit': 'uploadLinks',
    'click .cancel': 'closeModal'
  },

  ui: {
    'linksToUpload':   'textarea',
    'wrongInputError': '.wrong-input-error',
    'emptyError':      '.empty-error'
  },

  closeModal: function() {
    this.close();
  },

  uploadLinks: function() {
    var linksBucket,
        link;

    linksBucket = this.ui.linksToUpload.val();
    this.hideErrors();
    if (linksBucket !== "") {
      link = new Link({
        bucket: linksBucket
      });
      link.upload();
      this.close();
    } else {
      this.ui.emptyError.show();
    }
  },

  hideErrors: function() {
    this.ui.wrongInputError.hide();
    this.ui.emptyError.hide();
  }
});
