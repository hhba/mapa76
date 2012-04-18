mapa76
==========

Instalación:
--------------

Se asume un sistema linux o unix que cuenta con :

 - git   
 - ruby, rvm y bundler
 - mysql
 - mongodb
 - Las cabeceras de desarrollo de libxml2 y libxslt.
 
Copiar el repositorio localmente y poner a punto el entorno :

    $ rvm use 1.9.3
    $ git clone git://github.com/mapa76/alegato.git # commiters tienen otra url
    $ cd alegato
    $ bundle install

Configuración:
----------------

Modificar la configuración local:
    
    $ cp config/local_config.yaml.example config/local_config.yaml
    $ cp config/mongoid.yml.example config/mongoid.yml #XXX mover a local_config.yml
    $ vim config/local_config.yaml

La configuración por defecto apunta a un mongohq compartido: 
    mongodb://alegato:alegato@staff.mongohq.com:10014/alegato

Para actualizar una bd local desde mongohq:

    $ mongodump -v -h staff.mongohq.com --port 10014 -d alegato -username 'alegato' -password='alegato' -o ./dump
    $ mongorestore --host localhost  ./dump

Servidor de desarrollo:
------------------

Sobre la raiz del repositorio:

    $ padrino start
    
    ...
    => Padrino/0.10.6 has taken the stage development at http://0.0.0.0:3000

Ya podemos apuntar nuestro navegador a http://localhost:3000
