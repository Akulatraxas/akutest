ARG VERSION=latest
FROM python:3.12-slim-bookworm
ARG VERSION

RUN apt-get update && \
    apt-get install -y git \
            gettext \
            libpq-dev \
            locales \
            build-essential \
            sudo \
            locales \
            libmemcached-dev \
            zlib1g-dev \
            --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    dpkg-reconfigure locales && \
    locale-gen C.UTF-8 && \
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    mkdir /etc/pretalx && \
    mkdir /data && \
    mkdir /public && \
    groupadd -g 999 pretalxuser && \
    useradd -r -u 999 -g pretalxuser -d /pretalx -ms /bin/bash pretalxuser 

ENV LC_ALL=C.UTF-8

COPY deploy/docker/pretalx.bash /usr/local/bin/pretalx
COPY pretalx/pyproject.toml /pretalx
COPY pretalx/src /pretalx/src

RUN pip3 install -U pip setuptools wheel typing && \
    pip3 install -e /pretalx/[mysql,postgres,redis] && \
    pip3 install pylibmc && \
    pip3 install gunicorn


RUN apt-get update && \
    apt-get install -y nodejs npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    python3 -m pretalx rebuild

RUN chmod +x /usr/local/bin/pretalx && \
    cd /pretalx/src && \
    rm -f pretalx.cfg && \
    chown -R pretalxuser:pretalxuser /pretalx /data /public && \
    rm -f /pretalx/src/data/.secret

RUN echo $VERSION > /pretalx-build-version

USER pretalxuser
VOLUME ["/etc/pretalx", "/data", "/public"]
EXPOSE 80
ENTRYPOINT ["pretalx"]
CMD ["builder"]
