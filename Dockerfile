#
# Building
#

FROM debian:12.9-slim AS build

RUN apt update -yqq && \
    apt install -yq libvncserver-dev && \
    apt install -yq build-essential pkg-config make curl && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Build Bochs

WORKDIR /src

RUN curl -sL https://github.com/bochs-emu/Bochs/archive/refs/tags/REL_2_8_FINAL.tar.gz | tar xz --strip-components=1

WORKDIR /src/bochs

RUN ./configure --with-vncsrv --enable-ne2000 --enable-smp
RUN make


#
# Image Creation
#

FROM debian:12.9-slim

RUN apt update -yqq && \
    apt install -yq libvncserver1 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=build /src/bochs/bochs /usr/bin/bochs
COPY --from=build /src/bochs/bios/* /usr/share/bochs/bios/

# To ensure Bochs can find its BIOS files
ENV BXSHARE=/usr/share/bochs/bios


# /machine needs to be mounted from the host
WORKDIR /machine

# Quickstart Bochs without config
CMD ["bochs","-q"] 

