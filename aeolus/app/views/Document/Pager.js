
/**
 * VIEW: Pager
 * 
 */

var 
    template = require('./templates/pager.hbs');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,
  tagName: 'ul',
  ui:{
    input: 'input'
  },
  events:{
    'keypress input[name=go-to-page]': 'changePage',
    'click .next a': 'nextPage',
    'click .prev a': 'prevPage'
  },
  modelEvents: {
    'change:currentPage': 'render'
  },
  templateHelpers: function(){
    return {
      firstPage: this.model.get('currentPage') === 1,
      lastPage: this.model.get('currentPage') === this.model.get('pages')
    };
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  nextPage: function(event){
    this.model.moveToPage(this.model.get('currentPage') + 1);
    event.preventDefault();
  },

  prevPage: function(event){
    this.model.moveToPage(this.model.get('currentPage') - 1);
    event.preventDefault();
  },

  changePage: function(event){
    var num = this.ui.input.val();
    if(event.which === 13 || event.charCode === 13){
      if(!isNaN(num)){
        this.model.moveToPage(num);
      }
    }
  }
  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});