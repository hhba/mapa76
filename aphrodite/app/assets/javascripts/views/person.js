var PersonView = Backbone.View.extend({
  el: "#context",

  className: "person",

  initialize: function() {
    _.bindAll();
    this.template = $("#personContext").html();
    this.model.on("change", this.render, this);
  },

  render: function() {
    this.html = Mustache.render(this.template, this.model.toJSON());
    this.$el.html(this.html);
    $(".sidebar").mCustomScrollbar("update");
    return this;
  }
});