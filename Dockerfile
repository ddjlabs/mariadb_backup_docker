#NOTE: Using Alpine 3.12 as there are problems with the libfetch library pulling content via SSL for APK. 
# See this URL: https://github.com/alpinelinux/docker-alpine/issues/98

FROM alpine:3.12

#Set Build and Version information
ARG BUILD_DATE
ARG VERSION
LABEL build_version="version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="djenk43us"

WORKDIR /app

ENV TZ="UTC"
ENV DB_BACKUP_PATH "/backup"
ENV DB_INSTANCE="ALL"

#Mail Setup (environment variables)s
#ENV MAIL_HOST "smtp.gmail.com"
#ENV MAIL_PORT 587
#ENV MAIL_FROM "alerts@dougjenkins.com"
#ENV MAIL_USER "alerts@dougjenkins.com"
#ENV MAIL_USER_PASSWORD "OnAPtiAN"
#ENV MAIL_AUTH "on"
#ENV MAIL_TLS "on"
#ENV MAIL_TO "doug@dougjenkins.com"

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