FROM centos:7

RUN yum -y update && \
    yum -y install openssh tar git autoconf automake gcc kmod make perl-Sys-Syslog perl-Digest-MD5 libtirpc-devel && \
    yum clean all && \
    rm -rf /var/cache/yum/
WORKDIR /root

RUN git clone https://github.com/azenk/warewulf3.git && cd warewulf3 && git checkout ipxeversionembed
WORKDIR /root/warewulf3/common
RUN ./autogen.sh &&\
    ./configure --localstatedir /data &&\
    make &&\
    make install
WORKDIR /root/warewulf3/cluster
RUN ./autogen.sh && ./configure && make -j 8 && make install
WORKDIR /root/warewulf3/vnfs
RUN ./autogen.sh && ./configure && make -j 8 && make install
WORKDIR /root/warewulf3/provision
RUN yum install -y bzip2 libselinux-devel libuuid-devel device-mapper-devel xz-devel
RUN ./autogen.sh && ./configure && make -j 8 && make install

ADD https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.tgz /src/
RUN tar -zxf /src/consul-template_0.19.5_linux_amd64.tgz -C /usr/local/bin/

FROM quay.io/polargeospatialcenter/warewulf-sync:2019.06.17.121100

FROM centos:7

RUN yum -y update && \
    yum install -y which dhcp tftp-server sqlite perl-DBD-SQLite libtirpc perl-Sys-Syslog perl-Digest-MD5 perl-JSON-PP perl-CGI epel-release httpd && \
    yum install -y mod_perl jq git && \
    yum clean all && \
    rm -rf /var/cache/yum/

COPY --from=0 /usr/share/perl5/vendor_perl/Warewulf/ /usr/share/perl5/vendor_perl/Warewulf/
COPY --from=0 /usr/local/ /usr/local/
COPY --from=0 /data/ /buildtime-statedir/
COPY --from=1 /bin/warewulf-sync /usr/local/bin/warewulf-sync

COPY static/ /usr/local/share/warewulf/www
COPY healthcheck/health.pl /usr/local/libexec/warewulf/cgi-bin/health.pl
COPY healthcheck/health.conf /etc/httpd/conf.d/
COPY consul-template /etc/consul-template
COPY warewulf/ /usr/local/etc/warewulf/
COPY bin/ /usr/local/bin/
RUN mkdir -p /data/{db,binstore,config,tftp,warewulf} && \
    mkdir -p /data/warewulf/{bootstrap,ipxe} && \
    ln -s /usr/local/etc/httpd/conf.d/warewulf-httpd.conf /etc/httpd/conf.d/warewulf-httpd.conf &&\
    touch /var/www/html/index.html
