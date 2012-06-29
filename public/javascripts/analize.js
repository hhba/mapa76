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
    // TODO there should be a NamedEntityList Collection, with a comparator by
    // their "pos" attribute.
    this.namedEntities = new NamedEntityList(this.get("named_entities"));
    this.textLineList = new TextLineList(this.get("text_lines"));
  }
});

var TextLine = Backbone.Model.extend({});
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

var TextLineList = Backbone.Collection.extend({
  model: TextLine,

  comparator: function(textLine) {
    return textLine.get("num");
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
  el: $("#context"),

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

var NamedEntityView = Backbone.View.extend({
  el: $("#context"),

  initialize: function() {
    this.template = $("#namedEntityTemplate").html()
  },

  render: function() {
    this.html = Mustache.render(this.template, this.model.to.JSON());
  }
});

var AnalyzerView = Backbone.View.extend({
  el: $("#sidebar"),

  initialize: function() {
    this.template = $("#combTemplate").html();
  }
});

var DocumentView = Backbone.View.extend({
  el: $("#context"),

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
  events: {
    "click span": "selectNamedEntity"
  },

  template: $("#pageTemplate").html(),

  namedEntityTemplate: $("#namedEntityTemplate").html(),

  render: function() {
    var html = Mustache.render(this.template, this.namedEntitiesParse());
    this.$el.html(html);
    return this;
  },

  namedEntitiesParse: function() {
    var textLines = this.model.get("text_lines");
    var nes = this.model.get("named_entities");
    /*
    for(var i=0; i < nes.length; i++) {
      regExp = new RegExp("(" + nes[i].text + ")");
      content = content.replace(regExp, "<span class='ne " + nes[i].tag + "' data-ne-id='" + nes[i].id + "' data-type='" + nes[i].tag + "' data-person-id='" + nes[i].person_id +"'>" + "$1" + "</span>");
    }
    */
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
    var ne_type = $ne.attr("data-type");
    var person_id = $ne.attr("data-person-id");

    switch(ne_type) {
      case "people":
        if(person_id !== "null") {
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
  el: $(".pages"),

  className: "pages",

  events: {
    "scroll": "scrolling"
  },

  scrolling: function(e) {
    console.log(e);
  },

  render: function() {
    this.addAll();
    return this;
  },

  addOne: function(page) {
    var pageView = new PageView({ model: page });
    this.$el.append(pageView.render().el);
  },

  addAll: function() {
    this.collection.forEach(this.addOne, this);
    $(".page .ne").draggable({ helper: "clone" });
  },

  initialize: function() {
    this.collection.on("add", this.addOne, this);
    this.collection.on("reset", this.addAll, this);
  }
});

var RegisterView = Backbone.View.extend({
  el: "#register",

  events: {},

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
    output['document_id'] = AnalyzeApp.document.get("id");
    output['what'] = $("#whatSelector").val();
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

  addPage: function(data) {
    var url;
    var nextPageValues;
    var nextPage;
    $(".pages").append(Mustache.render(analyzer.pageTemplate, data));
    $("#loading").hide();
    if(!data.last_page) {
      nextPage = parseInt(data.current_page, 10) + 1;
      url = "/documents/" + data.document_id + "/comb?page=" + nextPage;
      nextPageValues = {
        url: url,
        id: data.document_id,
        'next_page': data.current_page + 1
      };
      $(".next_page").html(Mustache.render(analyzer.nextPageTemplate, nextPageValues));
      checkScroll();
    }
  }
};

function nearBottomOfPage() {
  return scrollDistanceFromBottom() < 200;
}

function scrollDistanceFromBottom(argument) {
  return pageHeight() - (window.pageYOffset + self.innerHeight);
}

function pageHeight() {
  return Math.max(document.body.scrollHeight, document.body.offsetHeight);
}

function checkScroll() {
  if (nearBottomOfPage()) {
    callNextPage();
  } else {
    window.setTimeout("checkScroll", 250);
  }
}

function callNextPage(){
  var url = "/api/documents/" + $("#next_page").attr("data-document") + "?page=" + $("#next_page").attr("data-next");
  $("#loading").show();
  $("#next_page").remove();
  $.getJSON(url, analyzer.addPage);
}

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

    /*
    this.document = new Document({ id: document_id });
    this.documentView = new DocumentView({ model: this.document });
    this.document.fetch();
    */

    this.pageList = new PageList();
    this.pageList.url = "/api/documents/" + document_id;
    this.pageListView = new PageListView({ collection: this.pageList });

    /*
    this.register = new Register();
    this.registerView = new RegisterView({ model: this.register });
    */
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

  $("#next_page").live("click", function() {
    callNextPage();
    return false;
  });

  $("#reference input").click(function() {
    var $this = $(this);
    var klass = $this.parent().attr("class");
    $(".pages ." + klass).toggle("nocolor");
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
