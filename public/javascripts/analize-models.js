var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/'
});
var Person = Backbone.Model.extend({
  urlRoot: "/api/people/"
});
var Paragraph = Backbone.Model.extend({});
var Register = Backbone.Model.extend({
  urlRoot: "/api/registers/",
  loadValues: function(info) {
    var that = this;
    _.each(info, function(value, key){
      that.set(key, value, {silent: true});
    });
    return that;
  },
  validate: function(attribs){
    console.log(attribs);
    if(attribs.who.length === 0) {
      return "There must be a who";
    } else if (attribs.when.length === 0) {
      return "There must be a when";
    } else if (attribs.what === null) {
      return "There must be a what";
    }
  },
  defaults: {
    who    : [],
    where  : [],
    when   : [],
    to_who : [],
    what   : []
  }
});
var ParagraphList = Backbone.Collection.extend({
  model: Paragraph,
  url: function(){
    return '/api/documents/' + this.get("document_id");
  }
});

