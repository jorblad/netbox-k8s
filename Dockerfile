ARG NETBOX_VERSION=4.7.0

FROM ghcr.io/netbox-community/netbox:v${NETBOX_VERSION}

COPY plugin_requirements.txt /opt/netbox/plugin_requirements.txt

RUN /usr/local/bin/uv pip install \
    --requirement /opt/netbox/plugin_requirements.txt