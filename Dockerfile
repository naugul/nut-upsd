FROM python:3.11.4-alpine3.18

LABEL maintainer="docker@naugul"

ENV NUT_VERSION 2.8.0

ENV UPS_NAME="ups"
ENV UPS_DESC="UPS"
ENV UPS_DRIVER="usbhid-ups"
ENV UPS_PORT="auto"

ENV API_PASSWORD="secret"
ENV ADMIN_PASSWORD="secret"

ENV SHUTDOWN_CMD="echo 'System shutdown not configured!'"

RUN set -ex; \
	# run dependencies
	apk add --no-cache \
		openssh-client \
		git \
		libusb-compat \
	; \
	# build dependencies
	apk add --no-cache --virtual .build-deps \
		libusb-compat-dev \
		build-base \
	; \
	# download and extract
	cd /tmp; \
	wget http://www.networkupstools.org/source/2.8/nut-$NUT_VERSION.tar.gz; \
	tar xfz nut-$NUT_VERSION.tar.gz; \
	cd nut-$NUT_VERSION \
	; \
	# build
	./configure \
		--prefix=/usr \
		--sysconfdir=/etc/nut \
		--disable-dependency-tracking \
		--enable-strip \
		--disable-static \
		--with-all=no \
		--with-usb=yes \
		--with-serial=yes \
		--datadir=/usr/share/nut \
		--with-drvpath=/usr/share/nut \
		--with-statepath=/var/run/nut \
		--with-user=nut \
		--with-group=nut \
	; \
	# install
	make install \
	; \
	# create nut user
	adduser -D -h /var/run/nut nut; \
	chgrp -R nut /etc/nut; \
	chmod -R o-rwx /etc/nut; \
	install -d -m 750 -o nut -g nut /var/run/nut \
	; \
	# cleanup
	rm -rf /tmp/nut-$NUT_VERSION.tar.gz /tmp/nut-$NUT_VERSION; \
	apk del .build-deps

#installing webnut...
RUN set -ex; \
	mkdir /var/run/nut/app; \
	cd /var/run/nut/app; \
	git clone https://github.com/rshipp/python-nut2.git; \
	cd python-nut2; \
	python setup.py install; \
	cd ..; \
	git clone https://github.com/rshipp/webNUT.git && cd webNUT; \
	pip install -e .

COPY ./src/entrypoint.sh /
RUN chmod +x /entrypoint.sh 
ENTRYPOINT ["/entrypoint.sh"]

WORKDIR /var/run/nut

EXPOSE 3493
EXPOSE 6543