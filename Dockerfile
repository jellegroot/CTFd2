FROM ctfd/ctfd

USER 0
WORKDIR /opt/CTFd

# Systeembibliotheken die plugins vaak nodig hebben
# hadolint ignore=DL3008
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        libssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Alleen jouw aangepaste code en plugins
COPY ./CTFd /opt/CTFd/CTFd
COPY ./CTFd/plugins /opt/CTFd/CTFd/plugins

# Plugin dependencies
# hadolint ignore=SC2086
RUN for d in CTFd/plugins/*; do \
        if [ -f "$d/requirements.txt" ]; then \
            pip install --no-cache-dir -r "$d/requirements.txt"; \
        fi; \
    done

# Permissions fixen
RUN chown -R 1001:1001 /opt/CTFd

USER 1001
EXPOSE 8000
ENTRYPOINT ["/opt/CTFd/docker-entrypoint.sh"]
