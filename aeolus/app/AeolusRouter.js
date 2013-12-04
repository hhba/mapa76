
module.exports = Backbone.Marionette.AppRouter.extend({ 
  
  routes : {
    "": "index",
    ":page": "loadPage",  // #5
  },

  initialize: function(options){
    this.document = options.document;
  },

  index: function(){
    this.loadPage(1);
  },

  loadPage: function(page){
    if (!isNaN(page)){
      this.document.moveToPage(parseInt(page, 10));
    }
  }

}); 