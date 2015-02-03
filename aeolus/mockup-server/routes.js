
module.exports = function(){

  app.get('/', function(req, res){
    res.send('Mockup Server');
  });

  app.get('/api/v2/documents', function(req, res){
    res.send(require('./data/documents'));
  });

  app.del('/api/v2/documents', function(req, res){
    res.send(204);
  });

  app.get('/api/v2/documents/search', function(req, res){
    res.send(require('./data/documents_search'));
  });

  app.get('/api/v2/documents/:id', function(req, res){
    res.send(require('./data/documents')[0]);
  });

  app.get('/api/v2/documents/:id/pages', function(req, res){
    res.send(204);
  });

  app.del('/api/v2/documents/:id', function(req, res){
    res.send(204);
  });

  app.get('/api/v2/documents/status', function(req, res){
    res.send(require('./data/status'));
  });

  app.get('/api/v2/people', function(req, res){
    res.send(require('./data/people'));
  });

  app.get('/api/v2/people/:id', function(req, res){
    res.send(require('./data/person'));
  });

};