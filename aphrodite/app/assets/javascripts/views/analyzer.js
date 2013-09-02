var AnalyzerView = Backbone.View.extend({
  el: "#sidebar",

  initialize: function() {
    this.template = $("#combTemplate").html();
  }
});