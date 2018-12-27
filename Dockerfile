# start with debian:stretch with ruby 2.3.x
FROM ruby:2.3

# app directory
WORKDIR /app

# install postgres 9.6
RUN apt-get update \
    && apt-get install -y apt-transport-https ca-certificates \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" >> /etc/apt/sources.list.d/yarn.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add --no-tty - \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add --no-tty - \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && alias node=nodejs \
    && apt-get update \
    && apt-get install -y nodejs yarn sudo nano build-essential libpq-dev postgresql-9.6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "postgres:postgres"  | chpasswd \
    && usermod -aG sudo postgres

USER postgres

# change postgres db user's password and allow easy access from remote psql
RUN /etc/init.d/postgresql start \
    && psql --command "ALTER USER postgres WITH PASSWORD 'postgres';" \
    && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.6/main/pg_hba.conf \
    && echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

# allow traffic for postgres and rails development
EXPOSE 5432 3000

VOLUME  ["/var/lib/postgresql"]

CMD ["/usr/lib/postgresql/9.6/bin/postgres", "-D", "/var/lib/postgresql/9.6/main", "-c", "config_file=/etc/postgresql/9.6/main/postgresql.conf"]
