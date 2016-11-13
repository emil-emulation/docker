FROM eaas/wildfly
CMD ["/sbin/my_init"]

COPY files/service /etc/service/
COPY files/init-scripts/ /etc/my_init.d/

RUN mkdir -p /eaas/deployments/
ADD eaas-server.ear /eaas/deployments/

ADD emil-ui-master /home/bwfla/emil-ui
ADD emil-admin-ui-master /home/bwfla/emil-admin-ui
#ADD emil-portable /home/bwfla/emil-portable
