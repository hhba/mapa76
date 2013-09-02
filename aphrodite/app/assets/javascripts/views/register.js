var RegisterView = Backbone.View.extend({
  el: "#register",

  render: function() {
    return this;
  },

  getValues: function() {
    var output = {};
    _.each(this.$el.find(".register"), function(span_ne) {
      var $span = $(span_ne);
      var group = $span.parent().attr("data-klass");
      var value = $span.attr("data-ne-id");
      if(_.isArray(output[group])) {
        var tmp = output[group];
        tmp.push(value);
        output[group] = tmp;
      } else {
        output[group] = [value];
      }
    });
    output.document_id = AnalyzeApp.document.get("id");
    output.what = $("#whatSelector").val();
    return output;
  },

  resetRegister: function() {
    $(".new_register").find(".register").remove();
    $(".sidebar").mCustomScrollbar("update");
    return this;
  }
});