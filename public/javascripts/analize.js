/**
 * Models
 **/
var Document = Backbone.Model.extend({
  urlRoot: '/api/documents/'
});

var Person = Backbone.Model.extend({
  urlRoot: "/api/people/"
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
    if(attribs.who.length === 0) {
      return "There must be a who";
    } else if (attribs.when.length === 0) {
      return "There must be a when";
    } else if (attribs.where.length === 0) {
      return "There must be a where";
    } else if (attribs.what === null) {
      return "There must be a what";
    }
  },

  defaults: {
    who    : [],
    where  : [],
    when   : [],
    to_who : [],
    what   : []
  }
});

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
    return this;
  }
});

/*
var NamedEntityView = Backbone.View.extend({
  el: "#context",

  initialize: function() {
    this.template = $("#namedEntityTemplate").html()
  },

  render: function() {
    this.html = Mustache.render(this.template, this.model.to.JSON());
  }
});
*/

var AnalyzerView = Backbone.View.extend({
  el: "#sidebar",

  initialize: function() {
    this.template = $("#combTemplate").html();
  }
});

var DocumentView = Backbone.View.extend({
  el: "#context",

  initialize: function() {
    this.template = $("#documentContextTemplate").html(),
    this.model.on('change', this.render, this)
  },

  render: function() {
    var html = Mustache.render(this.template, this.model.toJSON());
    this.$el.html(html);
    return this;
  }
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

  events: {
    "click .ne": "selectNamedEntity"
  },

  initialize: function() {
    this.$el = $("." + this.className + "[data-id=" + this.model.get("_id") + "]");
    this.template = $("#pageTemplate").html();
    this.namedEntityTemplate = $("#namedEntityTemplate").html();
  },

  render: function() {
    var html = Mustache.render(this.template, this.namedEntitiesParse());
    this.$el.html(html);
    this.$el.removeClass("empty").removeClass("fetching");
    this.$el.find(".page-content").fadeIn("fast");
    this.$el.find(".ne").draggable({ helper: "clone" });
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
        var person = new Person({ id: person_id })
        var personView = new PersonView({ model: person });
        person.fetch();
      }
      break;
    default:
      break;
    }
  }
});

var PageListView = Backbone.View.extend({
  el: ".pages",

  className: "pages",

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
  }
});

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
    return this;
  }
});

var analyzer = {
  init: function() {
    this.getTemplates();
  },

  getTemplates: function() {
    this.pageTemplate = $('#pageTemplate').html();
    this.nextPageTemplate = $("#nextPageTemplate").html();
  },
};

function Droppable(el){
  this.el = el;
  this.new_el = this.el.find(".new");
  this.new_el.droppable({
    drop: function(event, ui) {
      var draggable = ui.draggable;
      var template = $("#preRegisterTemplate").html();
      var params = {
        text: draggable.text(),
        type: draggable.attr("data-type"),
        ne_class: draggable.attr("data-class"),
        id: draggable.attr("data-ne-id")
      };
      $(this).before(Mustache.render(template, params));
      AnalyzeApp.register = new Register(AnalyzeApp.registerView.getValues());
    },
    accept: "." + this.el.attr("data-type")
  });
}

var AnalyzeApp = new (Backbone.Router.extend({
  initialize: function() {
    var document_id = $("#document-heading").attr("data-document-id");

    this.document = new Document({ id: document_id });
    this.documentView = new DocumentView({ model: this.document });
    this.document.fetch();

    this.pageList = new PageList();
    this.pageList.url = "/api/documents/" + document_id;
    this.pageListView = new PageListView({ collection: this.pageList });

    this.register = new Register();
    this.registerView = new RegisterView({ model: this.register });
  },

  saveRegister: function() {
    if (AnalyzeApp.register.isValid()) {
      AnalyzeApp.register.save();
      AnalyzeApp.registerView.resetRegister();
      $("#register-save").alert().show().fadeOut(2000);
    } else {
      $("#register-error").alert().show().fadeOut(2000);
    }
  }
}));


$(document).ready(function() {
  analyzer.getTemplates();

  window.droppable_klasses = ['who', 'when', 'where', 'to_who'];

  $("#reference input").click(function() {
    var $this = $(this);
    var klass = $this.parent().attr("class");
    $(".pages").toggleClass("hide-" + klass);
  });

  droppeables = _.map(window.droppable_klasses, function(klass) {
    return new Droppable($(".box." + klass));
  });

  $(".new_register button.close").live("click", function() {
    $(this).parent().remove();
  });

  $("button.clean").live("click", function() {
    AnalyzeApp.registerView.resetRegister();
  });

  $("button.save").live("click", function() {
    AnalyzeApp.saveRegister();
  });

  $("#whatSelector").change(function() {
    AnalyzeApp.register = new Register(AnalyzeApp.registerView.getValues());
  });
});
