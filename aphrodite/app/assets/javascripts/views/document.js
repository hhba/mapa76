var DocumentView = Backbone.View.extend({
  el: "#context",

  initialize: function() {
    this.template = $("#documentContextTemplate").html(),
    this.model.on('change', this.render, this);
    this.$el.spin({ top: 5, width: 3 });
  },

  render: function() {
    var html = Mustache.render(this.template, this.model.toJSON());
    this.$el.html(html);
    this.$el.find(".tablesorter").filter(function() {
      return $(this).find("tbody tr").length > 0;
    }).tablesorter({
      sortList: [[1,1]]
    });
    $(".sidebar").mCustomScrollbar("update");
    return this;
  }
});