var PageList = Backbone.Collection.extend({
  model: Page,

  comparator: function(page) {
    return page.get("num");
  }
});