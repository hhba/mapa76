var template = require('./templates/userMenu.tpl');

module.exports = Backbone.Marionette.ItemView.extend({

  //--------------------------------------
  //+ PUBLIC PROPERTIES / CONSTANTS
  //--------------------------------------

  template: template,

  templateHelpers: function(){
    var $projectData = $('body').data();
    return {
      loggedIn: $projectData.editable,
      userId: $projectData.userId,
      userName: $projectData.userName
    };
  }
});