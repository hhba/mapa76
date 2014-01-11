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

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    var
      self = this,
      currentPage = 1,
      $li = '',
      currentLi = '',
      scrollLevel = 0;

    this.$el.on('scroll', function(){
      scrollLevel = self.$el.scrollTop();
      currentLi = _.find(self.$el.find('li'), function(pageLi){
        $li = $(pageLi);
        return $li.position().top + $li.outerHeight() > 0;
      });

      currentPage = $(currentLi).data("num");

      if(self.model.get("currentPage") !== currentPage){
        self.model.moveToPage(currentPage);
      }
    });
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  scrollToPage: function(){
     var
       prevHeight = 0,
       currentPage = this.model.get('currentPage');

    _.each($('#page_' + currentPage).prevAll(), function(pageLi){
      prevHeight = prevHeight + $(pageLi).outerHeight();
    });

    this.$el.scrollTop(prevHeight);
    //aeolus.app.router.navigate('#' + currentPage, {trigger: true});
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

});