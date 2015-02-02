update:
	sudo docker pull malev/aphrodite:latest
	sudo docker pull malev/freeling:latest
	sudo docker pull malev/hephaestus:latest

consoleaphrodite:
	sudo docker run --env-file=config.dat -it --rm malev/aphrodite bundle exec rails c

stopaphrodite:
	sudo docker rm -f aphrodite-1
	sudo docker rm -f aphrodite-2
	sudo docker rm -f aphrodite-3
	sudo docker rm -f aphrodite-4
	sudo docker rm -f aphrodite-5

startaphrodite:
	sudo docker run -d -p 3001:8080 --env-file=config.dat --name=aphrodite-1 -v ~/log:/app/aphrodite/log malev/aphrodite
	sudo docker run -d -p 3002:8080 --env-file=config.dat --name=aphrodite-2 -v ~/log:/app/aphrodite/log malev/aphrodite
	sudo docker run -d -p 3003:8080 --env-file=config.dat --name=aphrodite-3 -v ~/log:/app/aphrodite/log malev/aphrodite
	sudo docker run -d -p 3004:8080 --env-file=config.dat --name=aphrodite-4 -v ~/log:/app/aphrodite/log malev/aphrodite
	sudo docker run -d -p 3005:8080 --env-file=config.dat --name=aphrodite-5 -v ~/log:/app/aphrodite/log malev/aphrodite

cleanschedulers:
	sudo docker run --env-file=config.dat -it --rm malev/hephaestus bundle exec rake workers:clean_schedulers

stopschedulers:
	sudo docker rm -f scheduler-1
	sudo docker rm -f scheduler-2
	sudo docker rm -f scheduler-3
	sudo docker rm -f scheduler-4
	sudo docker rm -f scheduler-5

startschedulers:
	sudo docker run -d --env-file=config.dat --name=scheduler-1 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work
	sudo docker run -d --env-file=config.dat --name=scheduler-2 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work
	sudo docker run -d --env-file=config.dat --name=scheduler-3 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work
	sudo docker run -d --env-file=config.dat --name=scheduler-4 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work
	sudo docker run -d --env-file=config.dat --name=scheduler-5 -v ~/log:/app/hephaestus/log -e QUEUE=scheduler malev/hephaestus bundle exec rake resque:work

consolehephaestus:
	sudo docker run --rm -it --env-file=config.dat -v ~/log:/app/hephaestus/log malev/hephaestus bundle exec rake console

indexes:
	sudo docker run --env-file=config.dat -it --rm -v ~/log:/app/aphrodite/log malev/aphrodite bundle exec rake db:mongoid:create_indexes

reindex:
	sudo docker run --env-file=config.dat -it --rm -v ~/log:/app/hephaestus/log malev/hephaestus bundle exec rake process:indexer
