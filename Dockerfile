FROM alpine:3.7

# Trick to add 32 bit libs
RUN echo "x86" > /etc/apk/arch

# Update and Upgrade system
RUN apk update && apk upgrade

# Add Packages
RUN apk add ca-certificates
RUN apk add wget
RUN apk add make
RUN apk add git
RUN apk add unzip
RUN apk add vim
RUN apk add less
RUN apk add man
RUN apk add libressl-dev

# CMake
RUN \ 
	CMAKE_VERSION=3.11.4 && \ 
	mkdir -p /tmp/cmake && \ 
	wget -q -O /tmp/cmake/cmake.sh https://cmake.org/files/v`expr "$CMAKE_VERSION" : '\([0-9][0-9]*\.[0-9][0-9]*\)'`/cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \ 
	chmod +x /tmp/cmake/cmake.sh && \ 
	./tmp/cmake/cmake.sh --prefix=/usr/local --exclude-subdir && \ 
	rm -rf /tmp/cmake

# Boost
RUN export BOOST_VERSION=1.68.0
RUN mkdir -p /tmp/boost
RUN wget -q -O /tmp/boost/boost.tar.gz https://dl.bintray.com/boostorg/release/${BOOST_VERSION}/source/boost_`echo $BOOST_VERSION | sed 's|\.|_|g'`.tar.gz
RUN	tar xfz /tmp/boost/boost.tar.gz -C /tmp/boost/ --strip-components=1
RUN cd /tmp/boost
RUN	./bootstrap.sh --prefix=/usr/local --with-libraries=system,chrono,thread,regex,date_time,atomic
RUN	./b2 variant=release link=static threading=multi address-model=32 runtime-link=shared -j2 -d0 install 
RUN	cd -
RUN	rm -rf /tmp/boost

COPY .bashrc /root

WORKDIR /root
CMD ["/bin/bash"]
