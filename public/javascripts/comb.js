/**
 * Models
 **/
var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/'
});

var Page = Backbone.Model.extend({
  initialize: function() {
    // FIXME filter "addresses", they are currently overlapping with other NEs
    // because of a bug. Remove this once solved.
    var nes = _.filter(this.get("named_entities"), function(ne) {
      return ne.ne_class != "addresses";
    });
    this.namedEntities = new NamedEntityList(nes);
  }
});

var NamedEntity = Backbone.Model.extend({});

/**
 * Collections
 **/
var PageList = Backbone.Collection.extend({
  model: Page,

  comparator: function(page) {
    return page.get("num");
  }
});

var NamedEntityList = Backbone.Collection.extend({
  model: NamedEntity,

  comparator: function(namedEntity) {
    return namedEntity.get("pos");
  }
});

/**
 * Views
 **/
var PageView = Backbone.View.extend({
  className: "page",

  attributes: function() {
    return {
      "id": this.model.get("num"),
      "data-id": this.model.get("_id"),
      "style": this.style()
    };
  },

  events: {
    "resize window": "resize"
  },

  style: function() {
    return "width: " + this.model.get("width") + "px; " +
           "height: " + this.model.get("height") + "px";
  },

  initialize: function() {
    this.$el = $("." + this.className + "[data-id=" + this.model.get("_id") + "]");
    this.template = $("#pageTemplate").html();
    this.namedEntityTemplate = $("#namedEntityTemplate").html();

    $(window).bind("resize.page." + this.model.get("num"), _.bind(this.resize, this));
  },

  remove: function() {
    $(window).unbind("resize.page." + this.model.get("num"));
  },

  render: function() {
    var html = Mustache.render(this.template, this.namedEntitiesParse());
    this.$el.html(html);
    this.$el.removeClass("empty").removeClass("fetching");
    this.$el.find(".page-content").fadeIn("fast");
    var pageViewEl = this.$el;
    this.$el.find(".ne").draggable({
      helper: function() {
        var neId = $(this).data("ne-id");
        var parts = pageViewEl.find(".ne[data-ne-id='" + neId + "']");
        var neInnerText = _.map(parts, function(e) { return e.innerText; }).join(" ")
        var helper = $(this).clone();
        helper.text(neInnerText);
        helper.css("opacity", "0.5");
        return helper;
      }
    });

    // Store original font-sze of each text line in a data attribute for later
    // dynamic resizing.
    // FIXME remove this once Document model (with fontspecs) is created
    this.$el.find("p").each(function(i, e) {
      var $e = $(e);
      $e.data("font-size", parseInt($e.css("font-size")));
      $e.data("top", parseInt($e.css("top")));
      $e.data("left", parseInt($e.css("left")));
    });

    // Trigger resize event
    this.resize();

    return this;
  },

  namedEntitiesParse: function() {
    var textLines = _.sortBy(this.model.get("text_lines"), "_id").map(function(textLine) {
      textLine.htmlText = textLine.text.replace(/\s/g, "&nbsp;");
      return textLine;
    });

    // Warning, this is ugly, shitty, kindergarten-level code. Needs a revamp ASAP
    if (this.model.namedEntities.size() > 0) {
      var neIdx = 0;
      var ne = this.model.namedEntities.at(neIdx);
      var nePos = ne.get("inner_pos");

      var pageView = this;
      _.each(textLines, function(textLine) {
        var curPos = 0;
        textLine.htmlText = "";
        while (curPos < textLine.processed_text.length) {
          if (ne && nePos.from.pid === pageView.model.get("_id") && nePos.to.pid === pageView.model.get("_id") &&
              nePos.from.tlid === textLine._id && nePos.to.tlid == textLine._id)
          {
            //console.log("complete entity on textline " + textLine._id);

            textLine.htmlText += textLine.processed_text.substring(curPos, nePos.from.pos).replace(/\s/g, "&nbsp;");
            ne.set("originalText", textLine.processed_text.substring(nePos.from.pos, nePos.to.pos + 1).replace(/\s/g, "&nbsp;"));
            var neHtml = Mustache.render(pageView.namedEntityTemplate, ne.toJSON());
            textLine.htmlText += neHtml;
            curPos = nePos.to.pos + 1;

            // update ne index and related variables
            neIdx += 1;
            ne = pageView.model.namedEntities.at(neIdx);
            if (ne) nePos = ne.get("inner_pos");

          } else if (ne &&
                     (!(nePos.from.pid === pageView.model.get("_id") && nePos.from.tlid === textLine._id) &&
                       (nePos.to.pid === pageView.model.get("_id") && nePos.to.tlid == textLine._id)) ||
                     ( (nePos.from.pid === pageView.model.get("_id") && nePos.from.tlid === textLine._id) &&
                      !(nePos.to.pid === pageView.model.get("_id") && nePos.to.tlid == textLine._id)) ) {

            //console.log("partial entity on textline " + textLine._id);

            if (nePos.from.pid === pageView.model.get("_id") && nePos.from.tlid === textLine._id) {
              var fromPos = nePos.from.pos;
            } else {
              var fromPos = 0;
            }

            if (nePos.to.pid === pageView.model.get("_id") && nePos.to.tlid == textLine._id) {
              var toPos = nePos.to.pos + 1;
            } else {
              var toPos = textLine.processed_text.length;
            }

            ne.set("originalText", textLine.processed_text.substring(fromPos, toPos).replace(/\s/g, "&nbsp;"));
            var neHtml = Mustache.render(pageView.namedEntityTemplate, ne.toJSON());
            textLine.htmlText += neHtml;

            curPos = toPos;

            // update ne index and related variables *only* if we are at the end of the NE (the latter half)
            if (nePos.to.pid === pageView.model.get("_id") && nePos.to.tlid == textLine._id) {
              neIdx += 1;
              ne = pageView.model.namedEntities.at(neIdx);
              if (!ne) break;
              nePos = ne.get("inner_pos");
            }

          } else {
            //console.log("no more entities on textline " + textLine._id);

            textLine.htmlText += textLine.processed_text.substring(curPos, textLine.processed_text.length).replace(/\s/g, "&nbsp;");
            curPos = textLine.processed_text.length;
          }
        }

      });
    }

    return {
      _id: this.model.get("_id"),
      width: this.model.get("width"),
      height: this.model.get("height"),
      textLines: textLines
    };
  },

  resize: function() {
    var currentWidth = this.$el.parents(".document").parents().width();
    var ratio = currentWidth / this.model.get("width");
    this.$el.find("p").each(function(i, e) {
      var $e = $(e);
      $e.css("font-size", parseInt($e.data("font-size")) * ratio);
      $e.css("top", parseInt($e.data("top")) * ratio);
      $e.css("left", parseInt($e.data("left")) * ratio);
    });
  }
});

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
            .each(function() { return self.fetchPage($(this)) });
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
      data: { page: num },
    });
  },

  selectNamedEntity: function(e) {
    var $ne = $(e.currentTarget);
    var ne_id = $ne.attr("data-ne-id");
    var ne_class = $ne.attr("data-class");
    var person_id = $ne.attr("data-person-id");

    this.$el.find(".ne.selected").removeClass("selected");
    this.$el.find(".ne[data-ne-id='" + ne_id + "']").addClass("selected");

    // Fetch NE profile info into Context view (people NE -> person profile)
    // TODO ...
  },

  addNamedEntityToCurrentFact: function(e) {
    console.log("addNamedEntityToCurrentFact");
    // TODO ...
  },
});


var AppView = Backbone.View.extend({
  initialize: function() {
    var document_id = $("#document-heading").attr("data-document-id");

    this.pageList = new PageList();
    this.pageList.url = "/api/documents/" + document_id;
    this.pageListView = new PageListView({ collection: this.pageList });
  }
});


$(function() {

});
