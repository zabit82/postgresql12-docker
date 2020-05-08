FROM ubuntu

RUN mkdir -p /docker-app/
WORKDIR /docker-app/
#COPY . /docker-app/
COPY alter_user.sql /tmp

ENV TZ Europe/Moscow


RUN set -eux; \
	groupadd -r postgres --gid=999; \
# https://salsa.debian.org/postgresql/postgresql-common/blob/997d842ee744687d99a2b2d95c1083a2615c79e8/debian/postgresql-common.postinst#L32-35
	useradd -r -g postgres --uid=999 --home-dir=/var/lib/postgresql --shell=/bin/bash postgres; \
# also create the postgres user's home directory with appropriate permissions
# see https://github.com/docker-library/postgres/issues/274
	mkdir -p /var/lib/postgresql; \
	chown -R postgres:postgres /var/lib/postgresql; \
	mkdir -p /etc/postgresql/12/main

RUN apt update
RUN apt install -y sudo bash bash-completion
RUN apt install -y lsb-release
RUN apt install -y wget gnupg2 tzdata
RUN echo deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main >  /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update
RUN apt install -y postgresql-12 mc nano
RUN sed -i -e"s/^#listen_addresses =.*$/listen_addresses = '*'/" /etc/postgresql/12/main/postgresql.conf
RUN echo "host    all    all    0.0.0.0/0    md5" >> /etc/postgresql/12/main//pg_hba.conf
RUN pg_ctlcluster 12 main start && \
    sudo -i -u postgres psql < /tmp/alter_user.sql && \
    pg_ctlcluster 12 main stop


#RUN lsb_release -cs
VOLUME ["/etc/postgresql/12/main", "/var/lib/postgresql/12"]

#ENTRYPOINT ["pg_ctlcluster", "12", "main", "start"]
#CMD [""]

EXPOSE 5432

#
CMD su postgres -c "/usr/lib/postgresql/12/bin/postgres -D /var/lib/postgresql/12/main -c config_file=/etc/postgresql/12/main/postgresql.conf"
