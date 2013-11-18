
module.exports = Backbone.Model.extend({
 
  defaults: {
    title: "Untitle",
    description: "None",

    people: 0,
    dates: 0,
    organizations: 0,
    places: 0,

    selected: false
  },

  flag: function(){
    $.ajax({
      url: this.url() + "/flag",
      type: "POST",
      cache: false,
      context: this
    }).done();
  }

});