/**
 * VIEW: Document List of Pages View
 * 
 */

var 
  template = require('./templates/content.tpl'),
  Page = require('./Page');

module.exports = Backbone.Marionette.CompositeView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  itemView: Page,
  tagName: 'ol',
  className: 'wrapper-doc',

  ui: {
    pages: 'ul.pages'
  },

  modelEvents: {
    'change:currentPage': 'changePage'
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    this.ui.pages.on('scroll', function(){
      // calculo de las paginas
      // aeolus.app.router.navigate('#5', {trigger: true});
    });

  },


  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  changePage: function(){
    // scroll to page
    //this.ui.pages
    // this.model.get('currentPage')
  }

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});