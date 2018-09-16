FROM centos:7

RUN yum -y update && \
    yum -y install openssh tar git autoconf automake gcc kmod make perl-Sys-Syslog perl-Digest-MD5 && \
    yum clean all && \
    rm -rf /var/cache/yum/
WORKDIR /root

RUN git clone https://github.com/azenk/warewulf3.git && cd warewulf3 && git checkout jsondump
WORKDIR /root/warewulf3/common
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /root/warewulf3/cluster
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /root/warewulf3/vnfs
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /root/warewulf3/provision
RUN yum install -y bzip2 libselinux-devel libuuid-devel device-mapper-devel xz-devel
RUN ./autogen.sh && ./configure && make && make install

ADD https://releases.hashicorp.com/consul-template/0.19.5/consul-template_0.19.5_linux_amd64.tgz /src/
RUN tar -zxf /src/consul-template_0.19.5_linux_amd64.tgz -C /usr/local/bin/

FROM centos:7

RUN yum -y update && \
    yum install -y which dhcp tftp-server sqlite perl-DBD-SQLite perl-Sys-Syslog perl-Digest-MD5 perl-JSON-PP epel-release httpd && \
    yum install -y mod_perl && \
    yum clean all && \
    rm -rf /var/cache/yum/

COPY --from=0 /usr/share/perl5/vendor_perl/Warewulf/ /usr/share/perl5/vendor_perl/Warewulf/
COPY --from=0 /usr/local/ /usr/local/

COPY consul-template /etc/consul-template
COPY warewulf/ /usr/local/etc/warewulf/
COPY bin/ /usr/local/bin/
RUN mkdir -p /data/{db,binstore} && \
    ln -s /data/binstore /usr/local/var/warewulf/binstore && \
    ln -s /usr/local/etc/httpd/conf.d/warewulf.conf /etc/httpd/conf.d/warewulf.conf
