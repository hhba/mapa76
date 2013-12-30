
/**
 * VIEW: Pager
 * 
 */

var 
    template = require('./templates/pager.tpl');

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
    'keypress input[name=go-to-page]': 'changePage'
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  changePage: function(event){
    var num = this.ui.input.val();
    if(event.which === 13 || event.charCode === 13){
      if(!isNaN(num)){
        console.log(num);
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