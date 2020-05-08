FROM ubuntu

RUN mkdir -p /docker-app/
WORKDIR /docker-app/
COPY alter_user.sql /tmp

ENV TZ=Europe/Moscow
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN set -eux; \
	groupadd -r postgres --gid=999; \
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql; \
	mkdir -p /etc/postgresql/12/main

RUN apt update
RUN apt install -y sudo bash bash-completion lsb-release wget gnupg2 tzdata mc nano
RUN echo deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main >  /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update
RUN apt install -y postgresql-12
RUN sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
RUN echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/12/main//pg_hba.conf
RUN pg_ctlcluster 12 main start && \
    sudo -i -u postgres psql < /tmp/alter_user.sql && \
    pg_ctlcluster 12 main stop

VOLUME ["/etc/postgresql/12/main", "/var/lib/postgresql/12"]
EXPOSE 5432

CMD su postgres -c "/usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/12/main -c config_file=/etc/postgresql/12/main/postgresql.conf"
