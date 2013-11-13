$(document).ready(function(){
  if($('#content-caroufredsel').length) {
    $('#content-caroufredsel').carouFredSel({
        items       : 1,
        author        : false,
        height        : 377,
        width       : 567,
        pagination      : "#content-caroufredsel-pager",
        mousewheel      : true,
        auto        : true,
        circular      : true,
        infinite      : true,

        scroll: {
          items     : 1,
          duration    : 1000,
          pauseOnHover  : true
        }
      });
  }

  if($('#prefooter-caroufredsel').length) {
    $('#prefooter-caroufredsel').carouFredSel({
      items       : 6,
      author        : false,
      height        : 63,
      width       : 845,
      circular      : true,
      prev        : '#prev2',
      next        : '#next2',
      mousewheel      : true,
      auto        : false,
      infinite      : true,

      scroll: {
        items     : 1,
        duration    : 1000,
        pauseOnHover  : true
      }
    });
  }
});