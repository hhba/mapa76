setup:
	cp /home/deploy/apps/mapa76.info/aphrodite/current/config/application.yml.sample /home/deploy/apps/mapa76.info/aphrodite/shared/config/application.yml
	cp /home/deploy/apps/mapa76.info/aphrodite/current/config/elasticsearch.yml.sample /home/deploy/apps/mapa76.info/aphrodite/shared/config/elasticsearch.yml
	cp /home/deploy/apps/mapa76.info/aphrodite/current/config/mongoid.yml.sample /home/deploy/apps/mapa76.info/aphrodite/shared/config/mongoid.yml
	cp /home/deploy/apps/mapa76.info/aphrodite/current/config/resque.yml.sample /home/deploy/apps/mapa76.info/aphrodite/shared/config/resque.yml
	sudo ln -s /home/deploy/apps/mapa76.info/aphrodite/current/config/nginx.conf.sample /etc/nginx/sites-enabled/analice.me.conf
	sudo rm /etc/nginx/sites-enabled/default
	mkdir /home/deploy/apps/mapa76.info/log
	sudo iptables -A INPUT -p tcp --dport 6379 -j ACCEPT
