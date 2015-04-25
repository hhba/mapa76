function DropDown(el) {
  this.dd = el;
  this.initEvents();
}
DropDown.prototype = {
  initEvents : function() {
    var obj = this;

    obj.dd.on('click', function(){
      $(this).toggleClass('active');
      if($(this).hasClass('active')){
        return false;
      }
    });
  }
};

$(function() {
  window.dd = new DropDown($('#dd'));

  $(document).click(function() {
    $('.wrapper-dropdown').removeClass('active');
  });
});
