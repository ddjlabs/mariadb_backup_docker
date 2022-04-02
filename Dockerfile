#NOTE: Using Alpine 3.12 as there are problems with the libfetch library pulling content via SSL for APK. 
# See this URL: https://github.com/alpinelinux/docker-alpine/issues/98

FROM alpine:3.12

#Set Build and Version information
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="djenk41us"

WORKDIR /app

ENV TZ="UTC"
ENV DB_BACKUP_PATH "/backup"
ENV DB_INSTANCE="ALL"

#Copy over the key bash scripts to make the container work.
COPY app/*.sh ./

RUN apk update && \
	apk add --no-cache mariadb-client && \
	apk add --no-cache tzdata && \
	apk add --no-cache coreutils && \
	#apk add --no-cache mariadb-backup && \
	apk add --no-cache gzip && \
	apk add --no-cache mailx && \
	apk add --no-cache msmtp && \
	chmod a+x -R /app/ && \
	echo "${VERSION}|${BUILD_DATE}" > /app/build_info.txt

CMD "/app/init.sh"
