FROM phusion/baseimage:0.9.19

#ARG KNOWLEDGRD_BLOCKCHAIN=https://example.com/knowledgrd-blockchain.tbz2

ARG KNOWLEDGR_STATIC_BUILD=ON
ENV KNOWLEDGR_STATIC_BUILD ${KNOWLEDGR_STATIC_BUILD}
ARG BUILD_STEP
ENV BUILD_STEP ${BUILD_STEP}

ENV LANG=en_US.UTF-8

RUN \
    apt-get update && \
    apt-get install -y \
        autoconf \
        automake \
        autotools-dev \
        bsdmainutils \
        build-essential \
        cmake \
        doxygen \
        gdb \
        git \
        libboost-all-dev \
        libyajl-dev \
        libreadline-dev \
        libssl-dev \
        libtool \
        liblz4-tool \
        ncurses-dev \
        pkg-config \
        python3 \
        python3-dev \
        python3-jinja2 \
        python3-pip \
        nginx \
        fcgiwrap \
        awscli \
        jq \
        wget \
        virtualenv \
        gdb \
        libgflags-dev \
        libsnappy-dev \
        zlib1g-dev \
        libbz2-dev \
        liblz4-dev \
        libzstd-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    pip3 install gcovr

ADD . /usr/local/src/knowledgr

RUN \
    if [ "$BUILD_STEP" = "1" ] || [ ! "$BUILD_STEP" ] ; then \
    cd /usr/local/src/knowledgr && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_KNOWLEDGR_TESTNET=ON \
        -DLOW_MEMORY_NODE=OFF \
        -DCLEAR_VOTES=ON \
        -DSKIP_BY_TX_ID=ON \
        .. && \
    make -j$(nproc) chain_test test_fixed_string plugin_test && \
    ./tests/chain_test && \
    ./tests/plugin_test && \
    ./programs/util/test_fixed_string && \
    cd /usr/local/src/knowledgr && \
    doxygen && \
    PYTHONPATH=programs/build_helpers \
    python3 -m knowledgr_build_helpers.check_reflect && \
    programs/build_helpers/get_config_check.sh && \
    rm -rf /usr/local/src/knowledgr/build ; \
    fi

RUN \
    if [ "$BUILD_STEP" = "2" ] || [ ! "$BUILD_STEP" ] ; then \
    cd /usr/local/src/knowledgr && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr/local/knowledgrd-testnet \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_KNOWLEDGR_TESTNET=ON \
        -DLOW_MEMORY_NODE=OFF \
        -DCLEAR_VOTES=ON \
        -DSKIP_BY_TX_ID=ON \
        -DENABLE_SMT_SUPPORT=ON \
        -DKNOWLEDGR_STATIC_BUILD=${KNOWLEDGR_STATIC_BUILD} \
        .. && \
    make -j$(nproc) chain_test test_fixed_string plugin_test && \
    make install && \
    ./tests/chain_test && \
    ./tests/plugin_test && \
    ./programs/util/test_fixed_string && \
    cd /usr/local/src/knowledgr && \
    doxygen && \
    PYTHONPATH=programs/build_helpers \
    python3 -m knowledgr_build_helpers.check_reflect && \
    programs/build_helpers/get_config_check.sh && \
    rm -rf /usr/local/src/knowledgr/build ; \
    fi

RUN \
    if [ "$BUILD_STEP" = "1" ] || [ ! "$BUILD_STEP" ] ; then \
    cd /usr/local/src/knowledgr && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_BUILD_TYPE=Debug \
        -DENABLE_COVERAGE_TESTING=ON \
        -DBUILD_KNOWLEDGR_TESTNET=ON \
        -DLOW_MEMORY_NODE=OFF \
        -DCLEAR_VOTES=ON \
        -DSKIP_BY_TX_ID=ON \
        -DCHAINBASE_CHECK_LOCKING=OFF \
        .. && \
    make -j$(nproc) chain_test plugin_test && \
    ./tests/chain_test && \
    ./tests/plugin_test && \
    mkdir -p /var/cobertura && \
    gcovr --object-directory="../" --root=../ --xml-pretty --gcov-exclude=".*tests.*" --gcov-exclude=".*fc.*" --gcov-exclude=".*app*" --gcov-exclude=".*net*" --gcov-exclude=".*plugins*" --gcov-exclude=".*schema*" --gcov-exclude=".*time*" --gcov-exclude=".*utilities*" --gcov-exclude=".*wallet*" --gcov-exclude=".*programs*" --gcov-exclude=".*vendor*" --output="/var/cobertura/coverage.xml" && \
    cd /usr/local/src/knowledgr && \
    rm -rf /usr/local/src/knowledgr/build ; \
    fi

RUN \
    if [ "$BUILD_STEP" = "2" ] || [ ! "$BUILD_STEP" ] ; then \
    cd /usr/local/src/knowledgr && \
    git submodule update --init --recursive && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr/local/knowledgrd-default \
        -DCMAKE_BUILD_TYPE=Release \
        -DLOW_MEMORY_NODE=ON \
        -DCLEAR_VOTES=ON \
        -DSKIP_BY_TX_ID=OFF \
        -DBUILD_KNOWLEDGR_TESTNET=OFF \
        -DKNOWLEDGR_STATIC_BUILD=${KNOWLEDGR_STATIC_BUILD} \
        .. \
    && \
    make -j$(nproc) && \
    make install && \
    cd .. && \
    ( /usr/local/knowledgrd-default/bin/knowledgrd --version \
      | grep -o '[0-9]*\.[0-9]*\.[0-9]*' \
      && echo '_' \
      && git rev-parse --short HEAD ) \
      | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n//g' \
      > /etc/knowledgrdversion && \
    cat /etc/knowledgrdversion && \
    rm -rfv build && \
    mkdir build && \
    cd build && \
    cmake \
        -DCMAKE_INSTALL_PREFIX=/usr/local/knowledgrd-full \
        -DCMAKE_BUILD_TYPE=Release \
        -DLOW_MEMORY_NODE=OFF \
        -DCLEAR_VOTES=OFF \
        -DSKIP_BY_TX_ID=ON \
        -DBUILD_KNOWLEDGR_TESTNET=OFF \
        -DKNOWLEDGR_STATIC_BUILD=${KNOWLEDGR_STATIC_BUILD} \
        .. \
    && \
    make -j$(nproc) && \
    make install && \
    rm -rf /usr/local/src/knowledgr ; \
    fi

RUN \
    apt-get remove -y \
        automake \
        autotools-dev \
        bsdmainutils \
        build-essential \
        cmake \
        doxygen \
        dpkg-dev \
        libboost-all-dev \
        libc6-dev \
        libexpat1-dev \
        libgcc-5-dev \
        libhwloc-dev \
        libibverbs-dev \
        libicu-dev \
        libltdl-dev \
        libncurses5-dev \
        libnuma-dev \
        libopenmpi-dev \
        libpython-dev \
        libpython2.7-dev \
        libreadline-dev \
        libreadline6-dev \
        libssl-dev \
        libstdc++-5-dev \
        libtinfo-dev \
        libtool \
        linux-libc-dev \
        m4 \
        make \
        manpages \
        manpages-dev \
        mpi-default-dev \
        python-dev \
        python2.7-dev \
        python3-dev \
    && \
    apt-get autoremove -y && \
    rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /var/cache/* \
        /usr/include \
        /usr/local/include

RUN useradd -s /bin/bash -m -d /var/lib/knowledgrd knowledgrd

RUN mkdir /var/cache/knowledgrd && \
    chown knowledgrd:knowledgrd -R /var/cache/knowledgrd

# add blockchain cache to image
#ADD $KNOWLEDGRD_BLOCKCHAIN /var/cache/knowledgrd/blocks.tbz2

ENV HOME /var/lib/knowledgrd
RUN chown knowledgrd:knowledgrd -R /var/lib/knowledgrd

VOLUME ["/var/lib/knowledgrd"]

# rpc service:
EXPOSE 8090
# p2p service:
EXPOSE 2001

# add seednodes from documentation to image
ADD doc/seednodes.txt /etc/knowledgrd/seednodes.txt

# the following adds lots of logging info to stdout
ADD contrib/config-for-docker.ini /etc/knowledgrd/config.ini
ADD contrib/fullnode.config.ini /etc/knowledgrd/fullnode.config.ini
ADD contrib/fullnode.opswhitelist.config.ini /etc/knowledgrd/fullnode.opswhitelist.config.ini
ADD contrib/config-for-broadcaster.ini /etc/knowledgrd/config-for-broadcaster.ini
ADD contrib/config-for-ahnode.ini /etc/knowledgrd/config-for-ahnode.ini

# add normal startup script that starts via sv
ADD contrib/knowledgrd.run /usr/local/bin/knowledgr-sv-run.sh
RUN chmod +x /usr/local/bin/knowledgr-sv-run.sh

# add nginx templates
ADD contrib/knowledgrd.nginx.conf /etc/nginx/knowledgrd.nginx.conf
ADD contrib/healthcheck.conf.template /etc/nginx/healthcheck.conf.template

# add PaaS startup script and service script
ADD contrib/startpaasknowledgrd.sh /usr/local/bin/startpaasknowledgrd.sh
ADD contrib/pulltestnetscripts.sh /usr/local/bin/pulltestnetscripts.sh
ADD contrib/paas-sv-run.sh /usr/local/bin/paas-sv-run.sh
ADD contrib/sync-sv-run.sh /usr/local/bin/sync-sv-run.sh
ADD contrib/healthcheck.sh /usr/local/bin/healthcheck.sh
RUN chmod +x /usr/local/bin/startpaasknowledgrd.sh
RUN chmod +x /usr/local/bin/pulltestnetscripts.sh
RUN chmod +x /usr/local/bin/paas-sv-run.sh
RUN chmod +x /usr/local/bin/sync-sv-run.sh
RUN chmod +x /usr/local/bin/healthcheck.sh

# new entrypoint for all instances
# this enables exitting of the container when the writer node dies
# for PaaS mode (elasticbeanstalk, etc)
# AWS EB Docker requires a non-daemonized entrypoint
ADD contrib/knowledgrdentrypoint.sh /usr/local/bin/knowledgrdentrypoint.sh
RUN chmod +x /usr/local/bin/knowledgrdentrypoint.sh
CMD /usr/local/bin/knowledgrdentrypoint.sh
