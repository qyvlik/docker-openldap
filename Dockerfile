

# https://gist.github.com/492162921/e5c00cbd6da99f702b9b2ed0e4432819

FROM ubuntu:20.04

ARG OPENLDAP_VERSION=2.4.57
ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Asia/Shanghai

RUN apt update &&\
    apt upgrade -y &&\
    apt install -y unixodbc make gcc libmysqlclient-dev unixodbc-dev groff ldap-utils wget curl

RUN mkdir -p /tmp/odbc &&\
    cd /tmp/odbc &&\
    wget https://downloads.mysql.com/archives/get/p/10/file/mysql-connector-odbc_8.0.28-1ubuntu20.04_amd64.deb &&\
    dpkg --force-all  -i ./mysql-connector-odbc_8.0.28-1ubuntu20.04_amd64.deb

RUN mkdir -p /tmp/download/openldap &&\
    cd /tmp/download/openldap &&\
    wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz &&\
    tar -xvzf openldap-${OPENLDAP_VERSION}.tgz &&\
    mv openldap-${OPENLDAP_VERSION} /opt/openldap &&\
    rm -rf /tmp/*

WORKDIR /opt/openldap

RUN ./configure --prefix=/usr \
      --exec-prefix=/usr \
      --bindir=/usr/bin \
      --sbindir=/usr/sbin \
      --sysconfdir=/etc \
      --datadir=/usr/share \
      --localstatedir=/var \
      --mandir=/usr/share/man \
      --infodir=/usr/share/info \
      --enable-sql \
      --disable-bdb \
      --disable-ndb \
      --disable-hdb &&\
    make depend &&\
    make &&\
    make install

COPY ./config/etc/*.ini /etc/
COPY ./config/etc/openldap/*.conf /etc/openldap/
COPY ./scripts/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 389
EXPOSE 636

CMD /docker-entrypoint.sh
