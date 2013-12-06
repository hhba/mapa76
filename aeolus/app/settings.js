
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
  };
};