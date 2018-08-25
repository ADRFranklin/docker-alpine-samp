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
RUN apk add --no-cache binutils cmake make libgcc musl-dev gcc g++

# CMake
RUN \ 
	CMAKE_VERSION=3.11.4 && \ 
	mkdir -p /tmp/cmake && \ 
	wget -q -O /tmp/cmake/cmake.sh https://cmake.org/files/v`expr "$CMAKE_VERSION" : '\([0-9][0-9]*\.[0-9][0-9]*\)'`/cmake-${CMAKE_VERSION}-Linux-x86_64.sh && \ 
	chmod +x /tmp/cmake/cmake.sh && \ 
	./tmp/cmake/cmake.sh --prefix=/usr/local --exclude-subdir && \ 
	rm -rf /tmp/cmake

# Boost
RUN \
    mkdir -p /tmp/boost && \
    wget -q -O /tmp/boost/boost.tar.gz https://dl.bintray.com/boostorg/release/1.68.0/source/boost_1_68_0.tar.gz && \
    tar xfz /tmp/boost/boost.tar.gz -C /tmp/boost/ --strip-components=1 && \
    cd /tmp/boost/ && \
    ./bootstrap.sh --prefix=/usr/local --with-libraries=system,chrono,thread,regex,date_time,atomic && \
    ./b2 variant=release link=static threading=multi address-model=32 runtime-link=shared -j2 -d0 install && \
    cd - && \
    rm -rf /tmp/boost

# SA-MP server + includes
RUN \ 
	mkdir -p /tmp/samp && \ 
	wget -q -O /tmp/samp/sampsvr-linux.tar.gz http://files.sa-mp.com/samp037svr_R2-2-1.tar.gz && \ 
	tar xfz /tmp/samp/sampsvr-linux.tar.gz -C /root/ && \ 
	wget -q -O /tmp/samp/sampsvr-win32.zip http://files.sa-mp.com/samp037_svr_R2-2-1_win32.zip && \ 
	unzip /tmp/samp/sampsvr-win32.zip pawno/include/* -d /root/samp03 && \ 
	rm -rf /tmp/samp

# PAWN compiler
RUN \ 
	PAWN_COMPILER_VERSION=3.10.8 && \ 
	mkdir -p /tmp/pawncc && \ 
	wget -q -O /tmp/pawncc/pawncc.tar.gz https://github.com/Southclaws/pawn/releases/download/v${PAWN_COMPILER_VERSION}/pawnc-${PAWN_COMPILER_VERSION}-linux.tar.gz && \ 
	tar xfz /tmp/pawncc/pawncc.tar.gz -C /usr/local/ --strip-components=1 && \
	rm -rf /tmp/pawncc

COPY .bashrc /root

WORKDIR /root
CMD ["/bin/bash"]
