ARG ARCH=arm64v8

FROM golang:1.13.2-alpine3.10

ARG VERSION=1.29.2664.67

WORKDIR /opt/pritunl

RUN set -x \
    && apk add -q --no-cache --virtual .build-deps \
        bzr curl gcc git go libffi-dev linux-headers \
        make musl-dev openssl-dev python2-dev py-pip

RUN apk add -q --no-cache \
        bash ca-certificates iptables ip6tables \
        openssl openvpn procps py2-setuptools \
        py2-dnspython tzdata

RUN pip install --upgrade pip

RUN go get github.com/pritunl/pritunl-dns \
    && go get github.com/pritunl/pritunl-web \
    && cp /go/bin/* /usr/bin

RUN cd /tmp \
    && curl -sSL https://github.com/pritunl/pritunl/archive/${VERSION}.tar.gz -o /tmp/${VERSION}.tar.gz \
    && tar -zxf /tmp/${VERSION}.tar.gz \
    && cd /tmp/pritunl-${VERSION} \
    && python2 setup.py build

RUN cd /tmp/pritunl-${VERSION} \
    && pip install -r requirements.txt

RUN cd /tmp/pritunl-${VERSION} \
    && python2 setup.py install \
    && apk del -q --purge .build-deps \
    && rm -rf /go /root/.cache/* /tmp/* /var/cache/apk/*

COPY ./docker-entrypoint.sh /opt/docker-entrypoint.sh

RUN chmod +x /opt/docker-entrypoint.sh

EXPOSE 80/tcp 443/tcp 1194/tcp 1194/udp 1195/udp 9700/tcp

ENTRYPOINT ["/opt/docker-entrypoint.sh"]

CMD ["pritunl"]

