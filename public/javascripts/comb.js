/**
 * Models
 **/
var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/',

  initialize: function() {
    this.pages = new Pages();
    this.pages.url = this.urlRoot + this.get("_id");
  }
});

var Page = Backbone.Model.extend({
  initialize: function() {
    // FIXME filter "addresses", they are currently overlapping with other NEs
    // because of a bug. Remove this once solved.
    var nes = this.get("named_entities").filter(function(ne) {
      return ne.ne_class != "addresses";
    });
    this.namedEntities = new NamedEntities(nes);
    this.textLines = new TextLines(this.get("text_lines"));
  }
});

var TextLine = Backbone.Model.extend({});
var NamedEntity = Backbone.Model.extend({
  initialize: function() {
    this.on("changed:selected", function() {
      console.log("selected! " + this.get("text"))
    }, this);
  }
});

var FactRegister = Backbone.Model.extend({});
var RelationRegister = Backbone.Model.extend({});

/**
 * Collections
 **/
var Pages = Backbone.Collection.extend({
  model: Page,

  comparator: function(page) {
    return page.get("num");
  }
});

var TextLines = Backbone.Collection.extend({
  model: TextLine,

  comparator: function(textLine) {
    return textLine.get("_id");
  }
});

var NamedEntities = Backbone.Collection.extend({
  model: NamedEntity,

  comparator: function(namedEntity) {
    return namedEntity.get("pos");
  },

  initialize: function() {
    this.on("change:selected", this.deselectAll, this);
  },

  deselectAll: function(changedNe) {
    if (changedNe.get("selected")) {
      this.each(function(ne) {
        if (ne.get("_id") !== changedNe.get("_id")) {
          ne.set("selected", false);
        }
      });
    }
  },
});

/**
 * Views
 **/
var AppView = Backbone.View.extend({
  initialize: function() {
    this.document = new Document(this.options.document);
    this.documentView = new DocumentView({ model: this.document });
  }
});

var DocumentView = Backbone.View.extend({
  className: "document",

  initialize: function() {
    this.pagesView = new PagesView({ collection: this.model.pages });
  }
});

var PagesView = Backbone.View.extend({
  el: ".pages",

  className: "pages",

  events: {
    "dblclick  .ne": "addNamedEntityToCurrentFact"
  },

  initialize: function() {
    this.collection.on("add", this.addOne, this);
    this.collection.on("reset", this.addAll, this);

    $(window).on("scroll.pages", _.bind(this.renderVisiblePages, this));
    $(window).on("mousedown.pages", _.bind(this.deselectNamedEntity, this));
  },

  remove: function() {
    $(window).off("scroll.pages");
    $(window).off("mousedown.pages");
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

  deselectNamedEntity: function() {
    this.$el.find(".ne.selected").removeClass("selected");
  },

  addNamedEntityToCurrentFact: function(e) {
    console.log("addNamedEntityToCurrentFact");
    // TODO ...
  },
});

var PageView = Backbone.View.extend({
  className: "page",

  attributes: function() {
    return {
      "id": this.model.get("num"),
      "data-id": this.model.get("_id"),
      "style": this.style()
    };
  },

  style: function() {
    return "width: " + this.model.get("width") + "px; " +
           "height: " + this.model.get("height") + "px";
  },

  initialize: function() {
    this.$el = $("." + this.className + "[data-id=" + this.model.get("_id") + "]");
    this.template = $("#page-template").html();

    $(window).on("resize.page." + this.model.get("num"), _.bind(this.resize, this));
  },

  remove: function() {
    $(window).off("resize.page." + this.model.get("num"));
  },

  render: function() {
    // Render empty page content
    this.$el.html(Mustache.render(this.template, this.model.toJSON()));

    // Append each rendered text line
    this.model.textLines.each(function(textLine) {
      // Build array of named entities for each text line
      var namedEntities = this.model.namedEntities.filter(function(ne) {
        var nePos = ne.get("inner_pos");
        return (nePos.from.pid  !== this.model.get("_id") ||
                nePos.to.pid    !== this.model.get("_id") ||
                (nePos.from.tlid <= textLine.get("_id") &&
                 nePos.to.tlid >= textLine.get("_id")));
      }, this);

      var textLineView = new TextLineView({
        model: textLine,
        pageId: this.model.get("_id"),
        namedEntities: namedEntities
      });

      this.$el.find(".page-content").append(textLineView.render().$el);
    }, this);

    // Show page content
    this.$el.removeClass("empty").removeClass("fetching");
    this.$el.find(".page-content").fadeIn("fast");

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

var TextLineView = Backbone.View.extend({
  model: TextLine,

  tagName: "p",

  attributes: function() {
    return {
      "data-id": this.model.get("_id"),
      "class": "fs" + this.model.get("fontspec_id"),
      "style": this.style()
    };
  },

  style: function() {
    return "top: " + this.model.get("top") + "px; " +
           "left: " + this.model.get("left") + "px; " +
           "width: " + this.model.get("width") + "px;";
  },

  initialize: function() {
    this.namedEntities = _(this.options.namedEntities || []);
    this.pageId = this.options.pageId;
  },

  render: function() {
    if (this.namedEntities.isEmpty()) {
      var content = this.model.get("processed_text");
      this.$el.append(content);

    } else {
      var curPos = 0;
      var neIdx = 0;
      var ne = this.namedEntities.value()[neIdx];
      var nePos = ne.get("inner_pos");

      while (curPos < this.model.get("processed_text").length) {
        if (ne && nePos.from.pid === this.pageId && nePos.to.pid === this.pageId &&
            nePos.from.tlid === this.model.get("_id") && nePos.to.tlid == this.model.get("_id"))
        {
          //console.log("complete entity on textline " + this.model.get("_id"));

          this.$el.append(this.model.get("processed_text").substring(curPos, nePos.from.pos).replace(/\s/g, "&nbsp;"));

          ne.set("originalText", this.model.get("processed_text").substring(nePos.from.pos, nePos.to.pos + 1).replace(/\s/g, "&nbsp;"));
          var neView = new NamedEntityView({ model: ne });
          this.$el.append(neView.render().$el);

          curPos = nePos.to.pos + 1;

          // update ne index and related variables
          neIdx += 1;
          ne = this.namedEntities.value()[neIdx]
          if (ne) nePos = ne.get("inner_pos");

        } else if (ne &&
                   (!(nePos.from.pid === this.pageId && nePos.from.tlid === this.model.get("_id")) &&
                     (nePos.to.pid === this.pageId && nePos.to.tlid == this.model.get("_id"))) ||
                   ( (nePos.from.pid === this.pageId && nePos.from.tlid === this.model.get("_id")) &&
                    !(nePos.to.pid === this.pageId && nePos.to.tlid == this.model.get("_id"))) ) {

          //console.log("partial entity on textline " + this.model.get("_id"));

          if (nePos.from.pid === this.pageId && nePos.from.tlid === this.model.get("_id")) {
            var fromPos = nePos.from.pos;
          } else {
            var fromPos = 0;
          }

          if (nePos.to.pid === this.pageId && nePos.to.tlid === this.model.get("_id")) {
            var toPos = nePos.to.pos + 1;
          } else {
            var toPos = this.model.get("processed_text").length;
          }

          ne.set("originalText", this.model.get("processed_text").substring(fromPos, toPos).replace(/\s/g, "&nbsp;"));
          var neView = new NamedEntityView({ model: ne });
          this.$el.append(neView.render().$el);

          curPos = toPos;

          // update ne index and related variables *only* if we are at the end of the NE (the latter half)
          if (nePos.to.pid === this.pageId && nePos.to.tlid === this.model.get("_id")) {
            neIdx += 1;
            ne = this.namedEntities.value()[neIdx];
            if (ne) nePos = ne.get("inner_pos");
          }

        } else {
          //console.log("no more entities on textline " + this.model.get("_id"));

          this.$el.append(this.model.get("processed_text").substring(curPos, this.model.get("processed_text").length).replace(/\s/g, "&nbsp;"));
          curPos = this.model.get("processed_text").length;
        }
      }
    }

    return this;
  }
});

var NamedEntityView = Backbone.View.extend({
  model: NamedEntity,

  tagName: "span",

  attributes: function() {
    return {
      "class": "ne " + this.model.get("ne_class"),
      "data-id": this.model.get("_id"),
      "data-class": this.model.get("ne_class"),
      "data-lemma": this.model.get("lemma"),
      "data-person-id": null
    };
  },

  events: {
    "mousedown": "select"
  },

  initialize: function() {
    this.model.on("change:selected", this.toggleSelect, this);
  },

  render: function() {
    this.$el.html(this.model.get("originalText"));
    this.$el.draggable(this.draggableOptions());
    return this;
  },

  allPartElements: function() {
    return $(this.tagName + "[data-id='" + this.attributes()["data-id"] + "']");
  },

  toggleSelect: function() {
    var $el = this.allPartElements();
    if (this.model.get("selected")) {
      $el.addClass("selected");
    } else {
      $el.removeClass("selected");
    }
  },

  select: function(e) {
    e.stopPropagation();
    this.model.set("selected", true);

    // Fetch NE profile info into Context view (people NE -> person profile)
    // TODO ...
  },

  draggableOptions: function() {
    var self = this;

    return {
      start: function(event, ui) {
        console.log("start");
      },

      stop: function(event, ui) {
        console.log("stop");
      },

      helper: function() {
        var parts = self.allPartElements();
        var helper = self.$el.clone().detach().appendTo(self.$el.parents(".pages"));
        var neInnerText = _.map(parts, function(e) { return e.innerText; }).join(" ")
        helper.text(neInnerText);

        var mainPart = $(_.max(parts, function(p) { return parseInt($(p).css("font-size")); }));
        helper.css("font", mainPart.css("font"));
        helper.css("margin", mainPart.css("margin"));
        helper.css("opacity", "0.5");
        return helper;
      }
    }
  }
});
