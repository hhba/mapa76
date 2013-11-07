var DocumentsView = Backbone.View.extend({
  template: JST['templates/documents'],
  el: '#documents',
  events: {
    'click .sort_title': 'sortByTitle',
    'click .sort_date': 'sortByDate',
    'click .select_all': 'selectAll'
  },
  initialize: function(){
    this.collection.on('reset', this.render, this);
  },
  render: function(){
    this.$el.html(this.template());
    return this;
  },
  sortByDate: function(event) {
    event.preventDefault();
    this.collection.fetch({reset: true, data: {sort: 'created_at'}});
  },
  sortByTitle: function(event) {
    event.preventDefault();
    this.collection.fetch({reset: true, data: {sort: 'title'}});
  },
  selectAll: function(event) {
    event.preventDefault();
    if(this._allChecked()) {
      $('.document_check').attr('checked', false);
    } else {
      $('.document_check').attr('checked', true);
    }
  },
  _allChecked: function() {
    return _.every($('.document_check'), function(checkbox){
      return checkbox.checked
    });
  }
});
