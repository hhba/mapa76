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