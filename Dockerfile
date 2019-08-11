FROM alpine:3.7

ENV SAMPCTL_VERSION=1.8.39
ENV LIBC32_DEB=libc6-i386_2.19-18+deb8u10_amd64.deb

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
    # Install Libc32
    ###    
    wget "http://ftp.us.debian.org/debian/pool/main/g/glibc/${LIBC32_DEB}" && \
    echo "aeee7bebb8e957e299c93c884aba4fa9  $LIBC32_DEB" | md5sum -c - && \ 
    ar p $LIBC32_DEB data.tar.xz | unxz | tar -x && \
    rm -rf $LIBC32_DEB /usr/share/doc/libc6-i386 /usr/lib32/gconv /usr/share/lintian && \
    apk del binutils && \
    rm -rf /var/lib/apk/lists/* && \    
    ###
    # Install sampctl
    ###
    mkdir -p /tmp/sampctl && \
    wget -q -O /tmp/sampctl/sampctl.tar.gz https://github.com/Southclaws/sampctl/releases/download/${SAMPCTL_VERSION}/sampctl_${SAMPCTL_VERSION}_linux_amd64.tar.gz && \
    cd /tmp/sampctl/ && \
    mkdir -p /tmp/sampctl/files && \
    tar xfz /tmp/sampctl/sampctl.tar.gz -C /tmp/sampctl/files && \
    mv /tmp/sampctl/files/sampctl /usr/local/bin && \
    rm -rf /tmp/sampctl

WORKDIR /samp
ENTRYPOINT ["sampctl", "package", "run"]
