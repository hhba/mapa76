function DropDown(el) {
  this.dd = el;
  this.initEvents();
}
DropDown.prototype = {
  initEvents : function() {
    var obj = this;

    obj.dd.on('click', function(event){
      $(this).toggleClass('active');
      if($(this).hasClass('active')){
        return false;
      }
    });
  }
}

$(function() {
  var dd = new DropDown( $('#dd'));

  $(document).click(function() {
    $('.wrapper-dropdown').removeClass('active');
  });
});