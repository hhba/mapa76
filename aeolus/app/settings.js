
module.exports = function() {
  var base = window.base;

  return {
      baseRoot: base.root
    , rootURL: (base.rootURL || base.root + "/api/") + (base.version || "v1")
    , imagesURL: base.root + "/images/"
    , authKey: "" // taken from body[data-user-auth]
    , headers: {
      xDocumentIds: "X-Document-Ids",
      authorization: "Authorization",
      xPages: "X-Pages"
    }
    , pagesRange: 4

    // time delay in milliseconds for getting the documents status
    // any falsy value to turn it off (i.e. 0, false, null, undefined)
    , poolingStatusTime: base.poolingStatusTime

    // Spinner Style
    , spinnerOptions: {
        lines: 9, // The number of lines to draw
        length: 11, // The length of each line
        width: 5, // The line thickness
        radius: 8, // The radius of the inner circle
        corners: 1, // Corner roundness (0..1)
        rotate: 0, // The rotation offset
        direction: 1, // 1: clockwise, -1: counterclockwise
        color: '#0889C5', // #rgb or #rrggbb or array of colors
        speed: 1, // Rounds per second
        trail: 60, // Afterglow percentage
        shadow: false, // Whether to render a shadow
        hwaccel: false, // Whether to use hardware acceleration
        className: 'spinner', // The CSS class to assign to the spinner
        zIndex: 2e9, // The z-index (defaults to 2000000000)
        top: 20, // Top position relative to parent in px
        left: 20 // Left position relative to parent in px
      }
  };
};