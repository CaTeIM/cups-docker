# syntax=docker/dockerfile:1

############################
# Etapa de build
############################
FROM ubuntu:latest AS build
ARG DEBIAN_FRONTEND=noninteractive
# Dependências de compilação
RUN apt-get update && apt-get install -y --no-install-recommends \
  git build-essential pkg-config autoconf automake libtool \
  avahi-daemon libavahi-client-dev libnss-mdns \
  libgnutls28-dev libpam0g-dev libdbus-1-dev libsystemd-dev \
  libusb-1.0-0-dev zlib1g-dev libpaper-dev ca-certificates \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /src
# Versão fixa do CUPS
ARG CUPS_REF=v2.4.14
RUN git clone --depth=1 --branch ${CUPS_REF} https://github.com/OpenPrinting/cups.git
WORKDIR /src/cups

# Configure e compile (ajuste do RuntimeDir para evitar /var/run)
RUN ./configure \
  --prefix=/usr \
  --sysconfdir=/etc \
  --localstatedir=/var \
  --with-gnutls \
  --with-dbus \
  --with-pam \
  --with-avahi \
  --with-rundir=/run/cups \
  && make -j"$(nproc)" \
  && make install DESTDIR=/tmp/pkg \
  && rm -rf /tmp/pkg/var/run || true

############################
# Etapa de runtime
############################
FROM ubuntu:latest
ARG DEBIAN_FRONTEND=noninteractive
# Dependências de execução e filtros
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates libgnutls30 libavahi-client3 libdbus-1-3 libusb-1.0-0 \
  libpam0g libpaper1 ghostscript cups-filters \
  && rm -rf /var/lib/apt/lists/*

# Instalar artefatos compilados
COPY --from=build /tmp/pkg/ /

# Porta IPP
EXPOSE 631

# Persistência
VOLUME ["/etc/cups","/var/spool/cups","/var/log/cups"]

# Executa em foreground
CMD ["/usr/sbin/cupsd","-f"]
