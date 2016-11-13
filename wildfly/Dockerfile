FROM eaas/bwfla:emil-base
CMD ["/sbin/my_init"]

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install openjdk-8-jre-headless -y  && apt-get clean

COPY fits /home/bwfla/fits
COPY appserver /home/bwfla/bw-fla-server
# Disable wildfly's security restrictions on management port when we run in Docker.
# This is not a problem, even if the management interface is bound to 0.0.0.0, because
# Docker won't expose this port automatically and we will only ever bind the management
# port to localhost, resulting in the same security as if we would run wildfly natively
# without Docker.
RUN sed -i 's/security-realm="ManagementRealm"//' /home/bwfla/bw-fla-server/standalone/configuration/standalone.xml
RUN chown -R bwfla:bwfla /home/bwfla/fits /home/bwfla/bw-fla-server
COPY files/EaasConf.xml /root/EaasConf.xml.default

COPY files/service /etc/service/
COPY files/init-scripts /etc/my_init.d/

RUN mkdir /eaas

EXPOSE 10809
