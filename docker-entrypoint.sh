#!/bin/bash -e

# Define a senha do usuário 'admin' usando a variável de ambiente ADMIN_PASSWORD
if [ -n "${ADMIN_PASSWORD}" ]; then
  echo "admin:${ADMIN_PASSWORD}" | chpasswd
fi

# Se a pasta de configuração montada estiver vazia, copia a configuração padrão
if [ ! -f /etc/cups/cupsd.conf ]; then
  cp -rpn /etc/cups-skel/* /etc/cups/
fi

# Executa o comando principal do container (o CMD do Dockerfile)
exec "$@"