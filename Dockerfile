FROM debian:stable-slim

RUN apt-get -y update && \
	apt-get -y upgrade && \
	apt-get install --no-install-recommends -y \
	wget \
	ca-certificates \
	autoconf \
	automake \
	build-essential \
	ccache \
	device-tree-compiler \
	dfu-util \
	file \
	g++ \
	gcc \
	gcc-multilib \
	git \
	iproute2 \
	libpcap-dev \
	libtool \
	make \
	ninja-build \
	python3-dev \
	python3-pip \
	python3-setuptools \
	xz-utils && \
	rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND noninteractive

RUN wget -q https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements.txt && \
	wget -q https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements-base.txt && \
	wget -q https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements-build-test.txt && \
	wget -q https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements-doc.txt && \
	wget -q https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements-run-test.txt && \
	wget -q https://raw.githubusercontent.com/zephyrproject-rtos/zephyr/master/scripts/requirements-extras.txt && \
	pip3 install wheel && \
	pip3 install -r requirements.txt && \
	pip3 install west && \
	pip3 install sh

ARG CMAKE_VERSION=3.16.2
RUN wget -q https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \
	chmod +x cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \
	./cmake-${CMAKE_VERSION}-Linux-x86_64.sh --skip-license --prefix=/usr/local && \
	rm -f ./cmake-${CMAKE_VERSION}-Linux-x86_64.sh

ARG ZSDK_TOOL=sdk
ARG ZSDK_VERSION=0.11.2
RUN wget -q "https://github.com/zephyrproject-rtos/sdk-ng/releases/download/v${ZSDK_VERSION}/zephyr-${ZSDK_TOOL}-${ZSDK_VERSION}-setup.run" && \
	sh "zephyr-${ZSDK_TOOL}-${ZSDK_VERSION}-setup.run" --quiet -- -d /opt/toolchains/zephyr-${ZSDK_TOOL}-${ZSDK_VERSION} && \
	rm "zephyr-${ZSDK_TOOL}-${ZSDK_VERSION}-setup.run"


ENV ZEPHYR_TOOLCHAIN_VARIANT=zephyr
ENV ZEPHYR_SDK_INSTALL_DIR=/opt/toolchains/zephyr-${ZSDK_TOOL}-${ZSDK_VERSION}

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
