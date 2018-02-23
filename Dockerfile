--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


                                  DOCKER FILE FOR NAGIOS 

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


FROM centos:7


MAINTAINER "Naveen Ram  <ramchowdary.pentyala@gmail.com>"


ENV NAGIOS_USER                nagios
ENV NAGIOS_CMD_GROUP	       nagcmd
ENV APACHE_USER                apache
ENV NAGIOS_TAR                 https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.1.1.tar.gz
ENV NAGIOS_SRC                 nagios-4.1.1
ENV NAGIOS_PLUGINS_TAR         http://nagios-plugins.org/download/nagios-plugins-2.1.1.tar.gz
ENV NAGIOS_PLUGINS_SRC	       nagios-plugins-2.2.1
ENV NAGIOS_NRPE_TAR	       http://downloads.sourceforge.net/project/nagios/nrpe-2.x/nrpe-2.15/nrpe-2.15.tar.gz
ENV NAGIOS_NRPE_SRC 	       nrpe-2.15

RUN yum update -y

RUN yum install gcc glibc glibc-common gd gd-devel make net-snmp openssl-devel openssl xinetd unzip wget curl -y

RUN yum install httpd -y 

RUN groupadd $NAGIOS_CMD_GROUP && useradd $NAGIOS_USER && usermod -aG $NAGIOS_CMD_GROUP $NAGIOS_USER

RUN curl -L -O $NAGIOS_TAR && tar xvf nagios-4.1.1.tar.gz

RUN cd $NAGIOS_SRC && ./configure --with-command-group=nagcmd 

RUN cd $NAGIOS_SRC &&make all && make install && make install-commandmode && make install-init && make install-config && make install-webconf

RUN usermod -G $NAGIOS_CMD_GROUP $APACHE_USER 

RUN cd / && curl -L -O $NAGIOS_PLUGINS_TAR  && tar xvf nagios-plugins-2.2.1.tar.gz

RUN cd $NAGIOS_PLUGINS_SRC && ./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl 

RUN cd $NAGIOS_PLUGINS_SRC && make && make install

RUN cd / && curl -L -O $NAGIOS_NRPE_TAR && tar xvf nrpe-2.15.tar.gz

RUN cd $NAGIOS_NRPE_SRC &&  make all && make install && make install-xinetd && make install-daemon-config 

RUN sed -i  's/only_from = 127.0.0.1 10.132.224.168/only_from = 127.0.0.1 192.168.4.32/g'  /etc/xinetd.d/nrpe

RUN service xinetd restart

RUN mkdir /usr/local/nagios/etc/servers

ADD http://192.168.4.15/nagios.cfg   /usr/local/nagios/etc/

ADD http://192.168.4.15/commands.cfg  /usr/local/nagios/etc/objects/

ADD http://192.168.4.15/foods.cfg    /usr/local/nagios/etc/servers/

RUN htpasswd -bc /usr/local/nagios/etc/htpasswd.users nagiosadmin naveen

RUN systemctl daemon-reload && systemctl start nagios && systemctl restart httpd

EXPOSE 80



