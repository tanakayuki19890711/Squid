FROM debian:bullseye as builder

ARG DEBIAN_FRONTEND=noninteractive

ENV SOURCEURL=http://www.squid-cache.org/Versions/v5/squid-5.7.tar.gz

ENV builddeps=" \
    build-essential \
    checkinstall \
    curl \
    devscripts \
    libcrypto++-dev \
    libssl-dev \
    openssl \
    "
ENV requires=" \
    libatomic1, \
    libc6, \
    libcap2, \
    libcomerr2, \
    libdb5.3, \
    libdbi-perl, \
    libecap3, \
    libexpat1, \
    libgcc1, \
    libgnutls30, \
    libgssapi-krb5-2, \
    libkrb5-3, \
    libldap-2.4-2, \
    libltdl7, \
    libnetfilter-conntrack3, \
    libnettle6, \
    libpam0g, \
    libsasl2-2, \
    libstdc++6, \
    libxml2, \
    netbase, \
    openssl \
    "
ENV prefix="/usr"

RUN echo "deb-src http://deb.debian.org/debian bullseye main" > /etc/apt/sources.list.d/source.list \
 && echo "deb-src http://deb.debian.org/debian bullseye-updates main" >> /etc/apt/sources.list.d/source.list \
#  && echo "deb-src http://security.debian.org bullseye/updates main" >> /etc/apt/sources.list.d/source.list \
 && echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list.d/source.list \
 && apt-get -qy update \
 && apt-get -qy install ${builddeps} \
 && apt-get -qy build-dep squid \
 && mkdir /build \
 && curl -o /build/squid-source.tar.gz ${SOURCEURL} \
 && cd /build \
 && tar --strip=1 -xf squid-source.tar.gz \
 && ./configure --with-openssl \
        --build=x86_64-linux-gnu \
        --prefix=/usr \
        --includedir=${prefix}/include \
        --mandir=${prefix}/share/man \
        --infodir=${prefix}/share/info \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --disable-option-checking \
        --disable-silent-rules \
        --libdir=${prefix}/lib/x86_64-linux-gnu \
        --runstatedir=/run \
        --disable-maintainer-mode \
        --disable-dependency-tracking \
#         BUILDCXXFLAGS=-g -O2 -ffile-prefix-map=/build/squid-Zv72wY/squid-5.6=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wno-error=deprecated-declarations -Wdate-time -D_FORTIFY_SOURCE=2 -Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now \
#         BUILDCXX=g++ \
        --with-build-environment=default \
        --enable-build-info="Ubuntu linux" \
        --datadir=/usr/share/squid \
        --sysconfdir=/etc/squid \
        --libexecdir=/usr/lib/squid \
        --mandir=/usr/share/man \
        --enable-inline \
        --disable-arch-native \
        --enable-async-io=8 \
        --enable-storeio=ufs,aufs,diskd,rock \
        --enable-removal-policies=lru,heap \
        --enable-delay-pools \
        --enable-cache-digests \
        --enable-icap-client \
        --enable-follow-x-forwarded-for \
        --enable-auth-basic=DB,fake,getpwnam,LDAP,NCSA,PAM,POP3,RADIUS,SASL,SMB \
        --enable-auth-digest=file,LDAP \
        --enable-auth-negotiate=kerberos,wrapper \
        --enable-auth-ntlm=fake,SMB_LM \
        --enable-external-acl-helpers=file_userip,kerberos_ldap_group,LDAP_group,session,SQL_session,unix_group,wbinfo_group \
        --enable-security-cert-validators=fake \
        --enable-storeid-rewrite-helpers=file \
        --enable-url-rewrite-helpers=fake \
        --enable-eui \
        --enable-esi \
        --enable-icmp \
        --enable-zph-qos \
        --enable-ecap \
        --disable-translation \
        --with-swapdir=/var/spool/squid \
        --with-logdir=/var/log/squid \
        --with-pidfile=/run/squid.pid \
        --with-filedescriptors=65536 \
        --with-large-files \
        --with-default-user=proxy \
        --enable-linux-netfilter \
        --with-systemd \
        --with-gnutls \
        --enable-http-violations \
#         build_alias=x86_64-linux-gnu \
#         build_alias=x86_64-linux-gnu \
#         CFLAGS=-g -O2 -ffile-prefix-map=/build/squid-Zv72wY/squid-5.6=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wno-error=deprecated-declarations \
#         LDFLAGS=-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now \
#         CPPFLAGS=-Wdate-time -D_FORTIFY_SOURCE=2 \
#         CXXFLAGS=-g -O2 -ffile-prefix-map=/build/squid-Zv72wY/squid-5.6=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wno-error=deprecated-declarations \


 && make -j$(awk '/^processor/{n+=1}END{print n}' /proc/cpuinfo) \
 && checkinstall -y -D --install=no --fstrans=no --requires="${requires}" \
        --pkgname="squid"

FROM debian:bullseye-slim

LABEL maintainer="Jacob Alberty <jacob.alberty@foundigital.com>"

ARG DEBIAN_FRONTEND=noninteractive

COPY --from=builder /build/squid_0-1_amd64.deb /tmp/squid.deb

RUN apt update \
 && apt -qy install curl \
 && curl -o /tmp/libnettle6.deb http://security.ubuntu.com/ubuntu/pool/main/n/nettle/libnettle6_3.2-1_amd64.deb \
 && apt -qy install libssl1.1 /tmp/squid.deb /tmp/libnettle6.deb \
 && apt-get install -y --no-install-recommends supervisor cron logrotate\
 && rm -rf /var/lib/apt/lists/*
 #  && apt-get install -y --no-install-recommends supervisor logrotate\
#  && rm -rf /var/lib/apt/lists/*

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY squid.conf /etc/squid.conf

# supervisordの設定ファイルをコピー
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir /var/spool/squid
RUN mkdir /var/log/squid

# ファイルの所有者を変更
# RUN chown nobody:nogroup /var/spool/squid /var/log/squid
RUN chown proxy:proxy /var/spool/squid /var/log/squid

# 権限追加
RUN chmod 4755 /usr/lib/squid/pinger

RUN touch /var/log/squid/access.log
RUN chmod 666 /var/log/squid/access.log

RUN touch /var/log/squid/cache.log
RUN chmod 666 /var/log/squid/cache.log

RUN touch /var/log/squid/store.log
RUN chmod 666 /var/log/squid/store.log

RUN touch /var/log/cron.log
RUN chmod 666 /var/log/cron.log

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

RUN chmod 777 /var/spool/squid

RUN echo cache_dir ufs /var/spool/squid 100 16 256 > /tmp/squid.conf

RUN squid -z -s -N -f /tmp/squid.conf

# cronの設定ファイルを追加
COPY cronjob /etc/cron.d/cronjob

# 所有者のみ書き込みと読み込みの権限追加
RUN chmod 777 /etc/cron.d/cronjob

# cronjobで毎日実行される定期的なジョブやスクリプトのスケジュールを定義
RUN crontab /etc/cron.d/cronjob

# ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 3128

CMD supervisord -c /etc/supervisor/supervisord.conf