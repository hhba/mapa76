/**
 * VIEW: Menu modal Collection
 * Must Inherit
 */

var LoadingView = require("../Loading");

module.exports = Backbone.Marionette.CollectionView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  tagName: "ul",
  className: "info-list clearfix",

  collectionEvents: {
    'request': 'showLoading',
    'sync': 'hideLoading'
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    this.showLoading();
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------
  
  showLoading: function(){
    var loading = new LoadingView();
    loading.render();
    this.$el.append(loading.$el);
  },

  hideLoading: function(){
    this.$el.children(".loading").remove();
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});