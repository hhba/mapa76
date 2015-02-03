from fabric.api import *

env.use_ssh_config = True

def install_databases():
    packages = ['mongodb', 'openjdk-7-jre', 'redis-tools', 'redis-server']
    sudo('apt-get update')
    sudo('apt-get install -y ' + ' '.join(packages))
    run('wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.deb')
    sudo('dpkg -i elasticsearch-1.4.2.deb')
    sudo("sed -i '/bind_ip = 127.0.0.1/c\bbind_ip = 0.0.0.0' /etc/mongodb.conf")
    sudo("sed -i '/bind 127.0.0.1/c\bind 0.0.0.0' /etc/redis/redis.conf")
    sudo('service mongodb restart')
    sudo('service redis-server restart')
    run('mkdir ~/backup')
    put('mongo-backup.sh', '~/backup')

def install_aphrodite():
    packages = ['nginx', 'docker.io', 'make']
    sudo('apt-get update')
    sudo('apt-get install -y ' + ' '.join(packages))
    put('nginx.conf', '~/')
    sudo('mv ~/nginx.conf /etc/nginx/sites-enabled/default')
    sudo('service nginx restart')

def deploy_aphrodite():
    put('config.dat', '~/')
    put('Makefile', '~/')
    sudo('docker pull malev/aphrodite:latest')
    with settings(warn_only=True):
        sudo('docker rm -f aphrodite-1')
        sudo('docker rm -f aphrodite-2')
        sudo('docker rm -f aphrodite-3')
        sudo('docker rm -f aphrodite-4')
        sudo('docker rm -f aphrodite-5')
    sudo('docker run -d -p 3001:8080 --env-file=config.dat --name=aphrodite-1 -v ~/log:/app/aphrodite/log malev/aphrodite')
    sudo('docker run -d -p 3002:8080 --env-file=config.dat --name=aphrodite-2 -v ~/log:/app/aphrodite/log malev/aphrodite')
    sudo('docker run -d -p 3003:8080 --env-file=config.dat --name=aphrodite-3 -v ~/log:/app/aphrodite/log malev/aphrodite')
    sudo('docker run -d -p 3004:8080 --env-file=config.dat --name=aphrodite-4 -v ~/log:/app/aphrodite/log malev/aphrodite')
    sudo('docker run -d -p 3005:8080 --env-file=config.dat --name=aphrodite-5 -v ~/log:/app/aphrodite/log malev/aphrodite')

def deploy_schedulers():
    put('config.dat', '~/')
    sudo('docker pull malev/hephaestus:latest')
    sudo('docker run --env-file=config.dat -it --rm -v ~/log:/app/hephaestus/log malev/hephaestus bundle exec rake workers:clean_schedulers')
    with settings(warn_only=True):
        sudo('docker rm -f scheduler-1')
        sudo('docker rm -f scheduler-2')
        sudo('docker rm -f scheduler-3')
        sudo('docker rm -f scheduler-4')
        sudo('docker rm -f scheduler-5')
    sudo('docker run -d --env-file=config.dat --name=scheduler-1 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=scheduler-2 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=scheduler-3 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=scheduler-4 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=scheduler-5 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work')

def deploy_hephaestus(restart=False):
    put('config.dat', '~/')
    sudo('docker pull malev/hephaestus:latest')
    sudo('docker pull malev/freeling-custom:latest')
    sudo('docker run --env-file=config.dat -it --rm -v ~/log:/app/hephaestus/log malev/hephaestus bundle exec rake workers:clean_but_schedulers')

    with settings(warn_only=True):
        sudo('docker rm -f freeling')
        sudo('docker rm -f hephaestus-freeling-1')
        sudo('docker rm -f hephaestus-freeling-2')
        sudo('docker rm -f hephaestus-database-1')
        sudo('docker rm -f hephaestus-database-2')
        sudo('docker rm -f hephaestus-database-3')
        sudo('docker rm -f hephaestus-database-4')
        sudo('docker rm -f hephaestus-io-1')
        sudo('docker rm -f hephaestus-io-2')
        sudo('docker rm -f hephaestus-io-3')
        sudo('docker rm -f hephaestus-io-4')
        sudo('docker rm -f hephaestus-text_extraction-1')
        sudo('docker rm -f hephaestus-text_extraction-2')
        sudo('docker rm -f hephaestus-calculation-1')
        sudo('docker rm -f hephaestus-calculation-2')

    sudo('docker run -d --name freeling -p 50005:50005 malev/freeling-custom')
    run('echo FREELING_HOST="$(sudo docker inspect --format \'{{ .NetworkSettings.IPAddress }}\' freeling)" >> config.dat')

    sudo('docker run -d --env-file=config.dat --name=hephaestus-freeling-1 -v ~/log:/app/hephaestus/log -e QUEUE=freeling malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-freeling-2 -v ~/log:/app/hephaestus/log -e QUEUE=freeling malev/hephaestus bundle exec rake resque:work')

    sudo('docker run -d --env-file=config.dat --name=hephaestus-database-1 -v ~/log:/app/hephaestus/log -e QUEUE=database malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-database-2 -v ~/log:/app/hephaestus/log -e QUEUE=database malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-database-3 -v ~/log:/app/hephaestus/log -e QUEUE=database malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-database-4 -v ~/log:/app/hephaestus/log -e QUEUE=database malev/hephaestus bundle exec rake resque:work')

    sudo('docker run -d --env-file=config.dat --name=hephaestus-io-1 -v ~/log:/app/hephaestus/log -e QUEUE=io malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-io-2 -v ~/log:/app/hephaestus/log -e QUEUE=io malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-io-3 -v ~/log:/app/hephaestus/log -e QUEUE=io malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-io-4 -v ~/log:/app/hephaestus/log -e QUEUE=io malev/hephaestus bundle exec rake resque:work')

    sudo('docker run -d --env-file=config.dat --name=hephaestus-text_extraction-1 -v ~/log:/app/hephaestus/log -e QUEUE=text_extraction malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-text_extraction-2 -v ~/log:/app/hephaestus/log -e QUEUE=text_extraction malev/hephaestus bundle exec rake resque:work')

    sudo('docker run -d --env-file=config.dat --name=hephaestus-calculation-1 -v ~/log:/app/hephaestus/log -e QUEUE=calculation malev/hephaestus bundle exec rake resque:work')
    sudo('docker run -d --env-file=config.dat --name=hephaestus-calculation-2 -v ~/log:/app/hephaestus/log -e QUEUE=calculation malev/hephaestus bundle exec rake resque:work')
