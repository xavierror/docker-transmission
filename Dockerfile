FROM ghcr.io/linuxserver/baseimage-alpine:3.13

ARG BUILD_DATE
ARG VERSION
ARG TRANSMISSION_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

RUN apk add --no-cache \
	ca-certificates \
	curl \
	findutils \
	jq \
	openssl \
	p7zip \
	python3 \
	rsync \
	tar \
	transmission-cli \
	transmission-daemon \
	unrar \
	unzip

RUN if [ -z ${TRANSMISSION_VERSION+x} ]; then \
	TRANSMISSION_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.13/community/x86_64/APKINDEX.tar.gz" | tar -xz -C /tmp \
	&& awk '/^P:transmission-daemon$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
 	fi && \
	apk add --no-cache \
	transmission-cli==${TRANSMISSION_VERSION} \
	transmission-daemon==${TRANSMISSION_VERSION}

RUN curl -o /tmp/combustion.zip -L "https://github.com/Secretmapper/combustion/archive/release.zip" && unzip /tmp/combustion.zip -d /

RUN mkdir -p /tmp/twctemp && \
	TWCVERSION=$(curl -sX GET "https://api.github.com/repos/xavierror/transmission-web-control/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]') && \
 	curl -o \
	/tmp/twc.tar.gz -L \
	"https://github.com/xavierror/transmission-web-control/archive/${TWCVERSION}.tar.gz" &&\
 	tar xf \
	/tmp/twc.tar.gz -C \
	/tmp/twctemp --strip-components=1 && \
 	mv /tmp/twctemp/src /transmission-web-control 

RUN rm -rf \
	/tmp/*


# copy local files
COPY root/ /

# ports and volumes
EXPOSE 9091 51413/tcp 51413/udp
VOLUME /config /downloads /watch
