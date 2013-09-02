var Register = Backbone.Model.extend({
  urlRoot: "/api/registers/",

  loadValues: function(info) {
    var that = this;
    _.each(info, function(value, key) {
      that.set(key, value, {silent: true});
    });
    return that;
  },

  validate: function(attribs) {
    console.log(attribs);
    if (attribs.who.length === 0) {
      return "There must be a who";
    } else if ($.trim(attribs.what) === "") {
      return "There must be a what";
    }
  },

  defaults: {
    who    : [],
    where  : [],
    when   : [],
    to_who : [],
    what   : ''
  }
});