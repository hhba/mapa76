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
  modelEvents: {
    'change:currentPage': 'changeCurrentPage'
  },

  //--------------------------------------
  //+ INHERITED / OVERRIDES
  //--------------------------------------

  onRender: function(){
    var self = this;
    this.$el.on('scroll', function(){
      self._changePageOnScrolling();
    });
  },

  //--------------------------------------
  //+ PUBLIC METHODS / GETTERS / SETTERS
  //--------------------------------------

  //--------------------------------------
  //+ EVENT HANDLERS
  //--------------------------------------

  changeCurrentPage: function(){
    if(!this._isCurrentPage()){
      this.dontUpdateScroll = true;
      this.scrollToPage();
    }
  },

  scrollToPage: function(){
    var
      prevHeight = 0,
      currentPage = this.model.get('currentPage');

    _.each($('#page_' + currentPage).prevAll(), function(pageLi){
      prevHeight = prevHeight + $(pageLi).outerHeight();
    });

    this.$el.scrollTop(prevHeight);
    aeolus.app.router.navigate('#' + currentPage, {trigger: true});
  },

  //--------------------------------------
  //+ PRIVATE AND PROTECTED METHODS
  //--------------------------------------

  _changePageOnScrolling: function(){
    var currentPage = this._currentScrollingPage();

    if(!this.dontUpdateScroll && !this._isCurrentPage()){
      this.model.moveToPage(currentPage);
      aeolus.app.router.navigate('#' + currentPage, {trigger: true});
    }
    this.dontUpdateScroll = false;
  },

  _currentScrollingPage: function(){
    var
      $li,
      currentLi;
    currentLi = _.find(this.$el.find('li'), function(pageLi){
      $li = $(pageLi);
      return $li.position().top + $li.outerHeight() > 0;
    });

    return $(currentLi).data('num');
  },

  _isCurrentPage: function(){
    return this._currentScrollingPage() === this.model.get('currentPage');
  },
});