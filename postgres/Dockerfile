FROM postgres:12.4

ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_USER=postgres
ENV POSTGRES_DB=postgres

ADD init_tables.sql /docker-entrypoint-initdb.d/init_tables.sql