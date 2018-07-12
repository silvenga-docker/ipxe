FROM ubuntu:18.04 as ipxe-builder

RUN set -xe \
    && DEBIAN_FRONTEND=noninteractive apt-get update -q \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gcc \
    binutils \
    make \
    perl \
    liblzma-dev \
    mtools \
    mkisofs \
    syslinux \
    isolinux \
    git

RUN set -xe \
    && mkdir -p /workspace/ \
    && git clone git://git.ipxe.org/ipxe.git /workspace/ipxe

COPY ./src /workspace/

RUN set -xe \
    && cd /workspace/ipxe/src \
    && make

RUN set -xe \
    && cd /workspace/ipxe/src \
    && make bin/undionly.kpxe EMBED=chain.ipxe \
    && make bin-x86_64-efi/ipxe.efi EMBED=chain.ipxe \
    && make bin/ipxe.iso EMBED=chain.ipxe

FROM busybox

COPY --from=ipxe-builder \
    /workspace/ipxe/src/bin/ipxe.iso \
    /workspace/ipxe/src/bin/ipxe.lkrn \
    /workspace/ipxe/src/bin/ipxe.pxe \
    /workspace/ipxe/src/bin/ipxe.usb \
    /workspace/ipxe/src/bin/undionly.kpxe \
    /workspace/ipxe/src/bin-x86_64-efi/ipxe.efi \
    ./data/