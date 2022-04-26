

# https://gist.github.com/492162921/e5c00cbd6da99f702b9b2ed0e4432819

FROM ubuntu

ARG OPENLDAP_VERSION=2.4.57

RUN apt update
RUN apt upgrade -y
RUN apt install -y unixodbc make gcc libmysqlclient-dev unixodbc-dev groff ldap-utils wget curl

COPY ./config/etc/*.ini /etc/

RUN mkdir -p /tmp/download
RUN cd /tmp/download
RUN wget ftp://ftp.openldap.org/pub/OpenLDAP/openldap-release/openldap-${OPENLDAP_VERSION}.tgz
RUN tar -xvzf openldap-${OPENLDAP_VERSION}.tgz
RUN mv openldap-${OPENLDAP_VERSION} /opt/openldap
RUN rm -rf /tmp/download/*

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
    --disable-hdb

RUN make depend
RUN make
RUN make install

COPY ./config/etc/openldap/*.conf /etc/openldap/
COPY ./scripts/docker-entrypoint.sh /docker-entrypoint.sh

EXPOSE 389
EXPOSE 636

CMD /docker-entrypoint.sh
