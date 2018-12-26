# start with debian:stretch with ruby 2.3.x
FROM ruby:2.3


# app directory
WORKDIR /app

# update
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add --no-tty - \
    && apt-get update \
    && apt-get install -y postgresql-9.6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER postgres

RUN /etc/init.d/postgresql start && \
    psql --command "ALTER USER postgres WITH PASSWORD 'postgres';" \
    && echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.6/main/pg_hba.conf \
    && echo "listen_addresses='*'" >> /etc/postgresql/9.6/main/postgresql.conf

EXPOSE 5432 3000

VOLUME  ["/var/lib/postgresql"]

CMD ["/usr/lib/postgresql/9.6/bin/postgres", "-D", "/var/lib/postgresql/9.6/main", "-c", "config_file=/etc/postgresql/9.6/main/postgresql.conf"]
