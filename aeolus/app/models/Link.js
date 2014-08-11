module.exports = Backbone.Model.extend({
  upload: function() {
    $.post(this.urlRoot() + '/links', {bucket: this.get('bucket')}, function(data) {
      console.log(data);
    });
  },

  urlRoot: function(){
    return aeolus.rootURL + "/documents";
  }
});
