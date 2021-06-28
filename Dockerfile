FROM maven:3.2.5-jdk-8 AS builder

ARG username
ARG port
ARG password
ARG ip
ARG name


WORKDIR /tmp
RUN git clone https://github.com/shephertz/App42PaaS-Java-MySQL-Sample.git

WORKDIR /tmp/App42PaaS-Java-MySQL-Sample
# RUN  sed -i '/^app42.paas.db.username/s/.*/app42.paas.db.username = "'${username}'"/g' WebContent/Config.properties \
#     && sed -i '/^app42.paas.db.port/s/.*/app42.paas.db.port = "'${port}'"/g' WebContent/Config.properties \
#     && sed -i '/^app42.paas.db.password/s/.*/app42.paas.db.password = "'${password}'"/g' WebContent/Config.properties \
#     && sed -i '/^app42.paas.db.ip/s/.*/app42.paas.db.ip = "'${ip}'"/g' WebContent/Config.properties \
#     && sed -i '/^app42.paas.db.name/s/.*/app42.paas.db.name = "'${name}'"/g' WebContent/Config.properties

RUN mvn package


FROM alpine:3.13
# Install Tomcat 9
RUN apk add openjdk8-jre \
    && wget http://apache.rediris.es/tomcat/tomcat-9/v9.0.48/bin/apache-tomcat-9.0.48.tar.gz -O /tmp/tomcat9.tar.gz \
    && mkdir /opt/tomcat \
    && tar xvzf /tmp/tomcat9.tar.gz  --strip-components 1 --directory /opt/tomcat \
    && rm /tmp/tomcat9.tar.gz

# Copy artifacts
WORKDIR /opt/tomcat/webapps
COPY --from=builder /tmp/App42PaaS-Java-MySQL-Sample/target/*.war .
COPY --from=builder /tmp/App42PaaS-Java-MySQL-Sample/WebContent/Config.properties ./ROOT/

# Container launch conditions
EXPOSE 8080
CMD ["/opt/tomcat/bin/catalina.sh", "run"]