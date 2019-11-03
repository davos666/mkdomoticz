FROM debian:stretch
MAINTAINER Josh Cox <josh 'at' webhosting.coop>
ENV MKDOMOTICZ_UPDATED=20190316

ARG DOMOTICZ_VERSION="development"

# install packages
RUN apt-get update && apt-get install -y \
	git \
	libssl1.0.2 libssl-dev \
	build-essential cmake \
	libboost-all-dev \
	libsqlite3-0 libsqlite3-dev \
	curl libcurl3 libcurl4-openssl-dev \
	libusb-0.1-4 libusb-dev \
	zlib1g-dev \
	libudev-dev \
	python3-dev python3-pip \
        wget && \
    # linux-headers-generic
apt remove --purge --auto-remove -y cmake && \
wget https://github.com/Kitware/CMake/releases/download/v3.16.0-rc2/cmake-3.16.0-rc2.tar.gz && \
tar -xzvf cmake-3.16.0-rc2.tar.gz && \
rm cmake-3.16.0-rc2.tar.gz && \
cd cmake-3.16.0-rc2 && \
./bootstrap && \
make && \
make install && \
cd .. && \
rm -Rf cmake-3.16.0-rc2 && \

apt remove --purge --auto-remove -y \
libboost-dev \
libboost-thread-dev \
libboost-system-dev \
libboost-atomic-dev \
libboost-regex-dev \
libboost-chrono-dev && \

mkdir boost && \
cd boost && \
wget https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz && \
tar xfz boost_1_71_0.tar.gz && \
cd boost_1_71_0/ && \
./bootstrap.sh && \
./b2 stage threading=multi link=static --with-thread --with-system && \
 ./b2 install threading=multi link=static --with-thread --with-system && \
cd ../../ && \
rm -Rf boost/ && \



## OpenZwave installation
# grep git version of openzwave
#git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
#cd /src/open-zwave && \
# compile
#make && \

# "install" in order to be found by domoticz
#ln -s /src/open-zwave /src/open-zwave-read-only && \

## Domoticz installation
# clone git source in src
git clone https://github.com/domoticz/domoticz.git /src/domoticz && \
# Domoticz needs the full history to be able to calculate the version string
cd /src/domoticz && \
#git fetch --unshallow && \
# prepare makefile
cmake -DCMAKE_BUILD_TYPE=Release . && \
# compile
make && \


# Install
# install -m 0555 domoticz /usr/local/bin/domoticz && \
cd /tmp && \
# Cleanup
# rm -Rf /src/domoticz && 
git clone https://github.com/ycahome/pp-manager.git /src/domoticz/plugins/pp-manager && \

# ouimeaux
pip3 install -U ouimeaux && \

# remove git and tmp dirs
#apt-get remove -y cmake linux-headers-amd64 build-essential libssl-dev libboost-dev libboost-thread-dev libboost-system-dev libsqlite3-dev libcurl4-openssl-dev libusb-dev zlib1g-dev libudev-dev && \
#   apt-get autoremove -y && \ 
#   apt-get clean && \
#   rm -rf /var/lib/apt/lists/*


VOLUME /config

EXPOSE 8080

COPY start.sh /start.sh

#ENTRYPOINT ["/src/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log"]
#CMD ["-www", "8080"]
CMD [ "/start.sh" ]
