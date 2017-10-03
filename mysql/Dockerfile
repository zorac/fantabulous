FROM percona:5.7
ENV MYSQL_DATABASE fantabulous
ENV MYSQL_USER admin
ENV MYSQL_PASSWORD changeme
ENV MYSQL_RANDOM_ROOT_PASSWORD yes
COPY fantabulous.sql /docker-entrypoint-initdb.d
