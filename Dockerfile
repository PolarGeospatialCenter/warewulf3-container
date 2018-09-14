FROM centos:7

RUN yum -y update && yum -y install openssh tar subversion autoconf automake gcc kmod && yum clean all
WORKDIR /root

RUN svn co --trust-server-cert --non-interactive  https://warewulf.lbl.gov/svn/trunk warewulf3
RUN yum install -y make
WORKDIR /root/warewulf3/common
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /root/warewulf3/cluster
RUN ./autogen.sh && ./configure && make && make install
WORKDIR /root/warewulf3/vnfs
RUN ./autogen.sh && ./configure && make && make install
RUN yum install -y perl-Sys-Syslog perl-Digest-MD5

