var PageListView = Backbone.View.extend({
  el: ".pages",

  className: "pages",

  events: {
    "mousedown .ne": "selectNamedEntity",
    "dblclick  .ne": "addNamedEntityToCurrentFact"
  },

  initialize: function() {
    this.collection.on("add", this.addOne, this);
    this.collection.on("reset", this.addAll, this);

    var self = this;
    $(window).scroll(function() {
      self.renderVisiblePages();
    });
  },

  render: function() {
    this.addAll();
    return this;
  },

  addOne: function(page) {
    var pageView = new PageView({ model: page });
    pageView.render();
  },

  addAll: function() {
    this.collection.each(this.addOne, this);
  },

  renderVisiblePages: function() {
    var self = this;
    this.$el.find(".page.empty")
            .filter(this.onViewport)
            .each(function() { return self.fetchPage($(this)); });
  },

  onViewport: function() {
    var rect = this.getBoundingClientRect();
    return (rect.top < window.innerHeight && rect.bottom > 0);
  },

  fetchPage: function($el) {
    var num = $el.attr("id");
    console.log("fetch page " + num);
    $el.removeClass("empty");
    $el.addClass("fetching");
    this.collection.fetch({
      add: true,
      data: { page: num }
    });
  },

  selectNamedEntity: function(e) {
    var $ne = $(e.currentTarget);
    var ne_id = $ne.attr("data-ne-id");
    var ne_class = $ne.attr("data-class");
    var person_id = $ne.attr("data-person-id");

    this.$el.find(".ne.selected").removeClass("selected");
    this.$el.find(".ne[data-ne-id='" + ne_id + "']").addClass("selected");

    switch (ne_class) {
    case "people":
      if (person_id !== "") {
        console.log("fetch person");
        var person = new Person({ id: person_id });
        var personView = new PersonView({ model: person });
        person.fetch();
      }
      break;
    default:
      break;
    }
  },

  addNamedEntityToCurrentFact: function(e) {
    var $ne = $(e.currentTarget);
    var neId = $ne.attr("data-ne-id");
    var neClass = $ne.attr("data-class");
    var parts = this.$el.find(".ne[data-ne-id='" + neId + "']");

    neData = {
      id: neId,
      neClass: neClass,
      type: $ne.attr("data-type"),
      text: _.map(parts, function(e) { return (e.innerText || e.textContent); }).join(" ")
    };

    switch (neClass) {
    case "people":
      if ($(".box.who .register").length === 0) {
        this.addToCurrentRegister(neData, "who");
      } else {
        this.addToCurrentRegister(neData, "to_who");
      }
      break;
    case "dates":
      $(".box.when .register").remove();
      this.addToCurrentRegister(neData, "when");
      break;
    case "places":
      $(".box.where .register").remove();
      this.addToCurrentRegister(neData, "where");
      break;
    case "actions":
      var verb = $ne.data("lemma");
      $("#whatSelector").val(verb);
      break;
    }
  },

  addToCurrentRegister: function(neData, boxClass) {
    var params = {
      text: neData.text,
      type: neData.type,
      ne_class: neData.neClass,
      id: neData.id
    };
    var template = $("#preRegisterTemplate").html();
    $(".box." + boxClass + " .new").before(Mustache.render(template, params));
    AnalyzeApp.register = new Register(AnalyzeApp.registerView.getValues());
    $(".sidebar").mCustomScrollbar("update");
  }
});