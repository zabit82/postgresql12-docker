 - docker build -t postgresql-server:12 ./postgresql12-docker/
 - docker run --name postgresql-srv -p 5432:5432 -d postgresql-server:12



