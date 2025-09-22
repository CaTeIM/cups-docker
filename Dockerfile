# Usa a imagem base do Ubuntu 24.04 LTS, que é moderna e estável
FROM ubuntu:24.04

# Argumento para evitar prompts durante a instalação
ARG DEBIAN_FRONTEND=noninteractive

# Variável de ambiente padrão para a senha do usuário 'admin' da interface web
ENV ADMIN_PASSWORD=admin

<<<<<<< HEAD
# Labels para documentar a imagem no Docker Hub
LABEL maintainer="cateim" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.name="cateim/cups" \
      org.label-schema.description="CUPS Server on Ubuntu 24.04" \
      org.label-schema.version="2.4.7"
=======
# Configure e compile (ajuste do RuntimeDir para evitar /var/run)
RUN arch="$(dpkg-architecture -q DEB_HOST_MULTIARCH)" \
  && ./configure \
      --prefix=/usr \
      --sysconfdir=/etc \
      --localstatedir=/var \
      --with-gnutls \
      --with-dbus \
      --with-pam \
      --with-avahi \
      --with-rundir=/run/cups \
      --libdir=/usr/lib/${arch} \
  && make -j"$(nproc)" \
  && make install DESTDIR=/tmp/pkg \
  && rm -rf /tmp/pkg/var/run || true
>>>>>>> f1015f024763b96475666bc36c2d9b9ebf1b9f70

# Instala o CUPS, filtros, drivers e outras utilidades via apt-get
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    sudo \
    cups \
    cups-bsd \
    cups-filters \
    foomatic-db-compressed-ppds \
    printer-driver-all \
    openprinting-ppds \
    hplip \
    avahi-daemon \
    libnss-mdns \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

<<<<<<< HEAD
# Cria um usuário 'admin' dedicado e dá as permissões corretas
RUN adduser --home /home/admin --shell /bin/bash --gecos "admin" --disabled-password admin \
 && adduser admin sudo \
 && adduser admin lp \
 && adduser admin lpadmin \
 && echo 'admin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
=======
# Instalar artefatos compilados
COPY --from=build /tmp/pkg/ /

RUN mkdir -p /run/cups && chown root:lp /run/cups
RUN ldconfig
>>>>>>> f1015f024763b96475666bc36c2d9b9ebf1b9f70

# Pré-configura o CUPS para aceitar conexões remotas e compartilhar impressoras
RUN /usr/sbin/cupsd \
 && while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
 && cupsctl --remote-admin --remote-any --share-printers \
 && kill $(cat /var/run/cups/cupsd.pid) \
 && echo "ServerAlias *" >> /etc/cups/cupsd.conf

# Salva uma cópia da configuração inicial para restaurar se o volume estiver vazio
RUN cp -rp /etc/cups /etc/cups-skel

# Copia e dá permissão de execução para o script de inicialização
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Define o script como ponto de entrada do container
ENTRYPOINT [ "docker-entrypoint.sh" ]

# Comando padrão para iniciar o CUPS
CMD ["cupsd", "-f"]

# Expõe a porta e define os volumes
EXPOSE 631
VOLUME ["/etc/cups", "/var/spool/cups", "/var/log/cups"]