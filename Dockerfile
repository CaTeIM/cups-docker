# Etapa de build
FROM debian:bookworm-slim AS build
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  git build-essential pkg-config autoconf automake libtool \
  libavahi-client-dev libgnutls28-dev libpam0g-dev libdbus-1-dev \
  libusb-1.0-0-dev zlib1g-dev libpaper-dev ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# Ajuste a versão conforme desejar (ex.: v2.4.12)
ARG CUPS_REF=master
RUN git clone --depth=1 --branch ${CUPS_REF} https://github.com/OpenPrinting/cups.git
WORKDIR /src/cups

RUN ./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --with-gnutls \
  --with-dbus \
  --with-pam \
  --with-avahi \
  && make -j"$(nproc)" \
  && make install DESTDIR=/tmp/pkg

# Etapa de runtime
FROM debian:bookworm-slim
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
  libgnutls30 libavahi-client3 libdbus-1-3 libusb-1.0-0 libpam0g \
  libpaper1 ghostscript cups-filters \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/pkg/ /

EXPOSE 631
VOLUME ["/etc/cups","/var/spool/cups","/var/log/cups"]

CMD ["/usr/sbin/cupsd","-f"]
