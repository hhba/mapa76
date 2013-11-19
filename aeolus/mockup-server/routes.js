
module.exports = function(){

  app.get('/', function(req, res){
    res.send('Mockup Server');
  });

  app.get('/api/v1/documents', function(req, res){
    res.send(require('./data/documents'));
  });

  app.del('/api/v1/documents', function(req, res){
    res.send(204);
  });

  app.get('/api/v1/documents/search', function(req, res){
    res.send(require('./data/documents_search'));
  });

  app.del('/api/v1/documents/:id', function(req, res){
    res.send(204);
  });

  app.get('/api/v1/documents/status', function(req, res){
    res.send(require('./data/status'));
  });

  app.get('/api/v1/people', function(req, res){
    res.send(require('./data/people'));
  });

  app.get('/api/v1/people/:id', function(req, res){
    res.send(require('./data/person'));
  });

};