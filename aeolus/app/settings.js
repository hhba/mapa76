
module.exports = function() {
  var base = window.base;

  return {
    baseRoot: base.root,
    rootURL: base.rootURL || base.root + '/api/v1',
    imagesURL: base.root + '/images/'
  };
};