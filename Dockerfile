FROM alpine:3.7

RUN \
    ##
    # Add x86 Libraries
    ##     
    echo "x86" > /etc/apk/arch && \
    ##
    # Upgrade system
    ##     
    apk update && apk upgrade && apk add --update binutils && \
    ##
    # Add packages
    ##     
    apk add --no-cache ca-certificates && \
    apk add --no-cache wget && \
    apk add --no-cache git && \
    apk add --no-cache libstdc++ && \
    ###
    # LIBC32
    ###    
    LIBC32_DEB=libc6-i386_2.19-18+deb8u10_amd64.deb && \
    wget "http://ftp.us.debian.org/debian/pool/main/g/glibc/libc6-i386_2.19-18+deb8u10_amd64.deb" && \
    echo "aeee7bebb8e957e299c93c884aba4fa9  $LIBC32_DEB" | md5sum -c - && \ 
    ar p $LIBC32_DEB data.tar.xz | unxz | tar -x && \
    rm -rf $LIBC32_DEB /usr/share/doc/libc6-i386 /usr/lib32/gconv /usr/share/lintian && \
    apk del binutils && \
    rm -rf /var/lib/apk/lists/* && \    
    ###
    # Install SAMPCTL
    ###
    mkdir -p /tmp/sampctl && \
    wget -q -O /tmp/sampctl/sampctl.tar.gz https://github.com/Southclaws/sampctl/releases/download/1.8.39/sampctl_1.8.39_linux_amd64.tar.gz && \
    cd /tmp/sampctl/ && \
    mkdir -p /tmp/sampctl/files && \
    tar xfz /tmp/sampctl/sampctl.tar.gz -C /tmp/sampctl/files && \
    mv /tmp/sampctl/files/sampctl /usr/local/bin && \
    rm -rf /tmp/sampctl

WORKDIR /samp
ENTRYPOINT ["sampctl", "package", "run"]
