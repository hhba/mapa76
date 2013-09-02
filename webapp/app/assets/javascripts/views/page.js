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
    this.template = $("#pageTemplate").html();
    this.namedEntityTemplate = $("#namedEntityTemplate").html();

    $(window).on("resize.page." + this.model.get("num"), _.bind(this.resize, this));
  },

  render: function() {
    var html = Mustache.render(this.template, this.namedEntitiesParse());
    this.$el.html(html);
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

    var pageViewEl = this.$el;
    this.$el.find(".ne").draggable({
      helper: function() {
        var neId = $(this).data("ne-id");
        var parts = pageViewEl.find(".ne[data-ne-id='" + neId + "']");
        var neInnerText = _.map(parts, function(e) { return (e.innerText || e.textContent); }).join(" ");
        var helper = $(this).clone();
        helper.text(neInnerText);
        helper.css("opacity", "0.5");
        return helper;
      }
    });
    return this;
  },

  resize: function() {
    var currentWidth = this.$el.parents(".document").parents().width();
    var ratio = currentWidth / this.model.get("width");
    this.$el.css("height", this.model.get("height") * ratio);
    this.$el.find("p").each(function(i, e) {
      var $e = $(e);
      $e.css("font-size", parseInt($e.data("font-size")) * ratio);
      $e.css("top", parseInt($e.data("top")) * ratio);
      $e.css("left", parseInt($e.data("left")) * ratio);
    });
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
  }
});