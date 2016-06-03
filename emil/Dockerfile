# DERIVING FROM MINIMALISTIC BWFLA IMAGE:
FROM eaas/bwfla:base

# EXECUTED DURING IMAGE BUILD:
ADD flavor-install     /home/bwfla/flavor-install
ADD flavor-start       /home/bwfla/flavor-start

RUN rm -rf /home/bwfla/appserver/standalone/configuration/standalone_xml_history
RUN DEBIAN_FRONTEND=noninteractive bash /home/bwfla/flavor-install && mv /tmp/objects /home/bwfla && rm /tmp/image-archive.tgz


# EXECUTED WHEN CONTAINER IS RUN:
CMD ["bash", "/home/bwfla/flavor-start"]
