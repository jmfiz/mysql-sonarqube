from dockerfile/java
maintainer jmfiz, jmfiz@paradigmatecnologico.com

RUN echo "deb http://downloads.sourceforge.net/project/sonar-pkg/deb binary/" >> /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y

####################################
# Sonar installation
####################################
RUN apt-get install -y --force-yes sonar

RUN sed -i 's|#wrapper.java.additional.6=-server|wrapper.java.additional.6=-server|g' /opt/sonar/conf/wrapper.conf

RUN sed -i 's|#sonar.jdbc.password=sonar|sonar.jdbc.password=123qwe|g' /opt/sonar/conf/sonar.properties
RUN sed -i 's|#sonar.jdbc.username=sonar|sonar.jdbc.username=sonar|g' /opt/sonar/conf/sonar.properties
RUN sed -i 's|sonar.jdbc.url=jdbc:h2|#sonar.jdbc.url=jdbc:h2|g' /opt/sonar/conf/sonar.properties
RUN sed -i 's|#sonar.jdbc.url=jdbc:mysql://localhost|sonar.jdbc.url=jdbc:mysql://localhost|g' /opt/sonar/conf/sonar.properties 

# download and install sonar plugins
RUN apt-get install -q -y wget
RUN apt-get install -q -y zip
RUN apt-get install -q -y expect
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/android/sonar-android-plugin/1.0/sonar-android-plugin-1.0.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/sonar-build-breaker-plugin/1.1/sonar-build-breaker-plugin-1.1.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/java/sonar-checkstyle-plugin/2.2/sonar-checkstyle-plugin-2.2.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/java/sonar-java-plugin/2.8/sonar-java-plugin-2.8.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/l10n/sonar-l10n-fr-plugin/1.10/sonar-l10n-fr-plugin-1.10.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/java/sonar-pmd-plugin/2.3/sonar-pmd-plugin-2.3.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/sonar-widget-lab-plugin/1.6/sonar-widget-lab-plugin-1.6.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/java/sonar-findbugs-plugin/3.1/sonar-findbugs-plugin-3.1.jar
RUN wget -P /opt/sonar/extensions/downloads/ http://repository.codehaus.org/org/codehaus/sonar-plugins/sonar-cobertura-plugin/1.6.3/sonar-cobertura-plugin-1.6.3.jar

#android sdk for sonar-android analyses (lint tools)
RUN wget http://dl.google.com/android/android-sdk_r24-linux.tgz -O /opt/android-sdk_r24-linux.tgz
RUN tar xf /opt/android-sdk_r24-linux.tgz -C /opt/
ENV ANDROID_HOME /opt/android-sdk-linux
RUN chmod -R 777 /opt/android-sdk-linux

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

RUN mkdir -p /opt/tools
COPY sdk_android.sh /opt/tools/android-accept-licenses.sh
ENV PATH ${PATH}:/opt/tools

RUN chmod 755 /opt/tools/android-accept-licenses.sh
RUN ["/opt/tools/android-accept-licenses.sh", "android update sdk --filter tools --no-ui --all"]
RUN chmod -R 777 /opt/android-sdk-linux


####################################
# MYSQL installation
####################################
RUN dpkg-divert --local --rename --add /sbin/initctl

RUN echo "deb http://archive.ubuntu.com/ubuntu trusty main universe" > /etc/apt/sources.list
RUN apt-get update && apt-get upgrade -y

ADD create_database.sql /tmp/create_database.sql

RUN apt-get install -y mysql-server

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

RUN /usr/bin/mysqld_safe & \
    sleep 10s && \
    mysql -u root < /tmp/create_database.sql

####################
# Start.sh
####################
ADD start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

VOLUME ["/etc/mysql", "/var/lib/mysql", "/var/log/mysql", "/opt/sonar"]

#Expose sonar port
EXPOSE 3306
EXPOSE 9000

CMD ["/usr/local/bin/start.sh", "-n"]
