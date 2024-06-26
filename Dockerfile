ARG  FROMIMAGE=default-route-openshift-image-registry.apps.ocp-6640020dli-ohb8.cloud.techzone.ibm.com/rashid/ace-server-prod:12.0.10.0-r3

# default-route-openshift-image-registry.apps.ocp-6640020dli-abby.cloud.techzone.ibm.com/rashid/ace-server-prod:12.0.11.2-r1
# default-route-openshift-image-registry.apps.ocp-6640020dli-7cyg.cloud.techzone.ibm.com/rashid/ace-server-prod:12.0.11.2-r1
# 12.0.11.2-r1 - cp.icr.io/cp/appc/ace-server-prod@sha256:c45d6e2bb78f0bad4865d38b52117fe8f57e2ef6c17d434a67c63838eef22d2d

#default-route-openshift-image-registry.apps.ocp-6640020dli-abby.cloud.techzone.ibm.com/rashid/ace-server-prod:12.0.9.0-r3-lts
#cp.icr.io/cp/appc/ace-server-prod@sha256:c41154c17a30bbbb6e1e4593c965f49ef3c86260e71143b8f33a6fbca277a3b9
FROM ${FROMIMAGE}

USER root

# Copy the BAR files into /tmp and process them:
#
# - Each file is compiled to ensure faster server startup
# - The files are unpacked into the server work directory
# - Once all files are in place, the work directory is optimized to speed up server start
# - The contents are made world-writable to allow for random userids at runtime
#
# The results of the commands can be found in the /tmp/deploys file.
#
COPY *.bar /tmp
RUN export LICENSE=accept \
    && . /opt/ibm/ace-12/server/bin/mqsiprofile \
    && set -x && for FILE in /tmp/*.bar; do \
       echo "$FILE" >> /tmp/deploys && \
       ibmint package --compile-maps-and-schemas --input-bar-file "$FILE" --output-bar-file /tmp/temp.bar  2>&1 | tee -a /tmp/deploys && \
       ibmint deploy --input-bar-file /tmp/temp.bar --output-work-directory /home/aceuser/ace-server/ 2>&1 | tee -a /tmp/deploys; done \
    && ibmint optimize server --work-dir /home/aceuser/ace-server \
    && chmod -R ugo+rwx /home/aceuser/

USER 1001
