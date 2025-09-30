# Servidor de Impressão CUPS - Imagem Docker Multi-Arquitetura

![GitHub Workflow Status](https://img.shields.io/github/actions/workflow/status/CaTeIM/cups-docker/cups.yml?branch=main&style=for-the-badge)
![Docker Hub Pulls](https://img.shields.io/docker/pulls/cateim/cups?style=for-the-badge)
![Docker Image Size](https://img.shields.io/docker/image-size/cateim/cups/latest?style=for-the-badge)

Esta é uma imagem Docker multi-arquitetura do **[CUPS (Common Unix Printing System)](https://github.com/OpenPrinting/cups)**, construída sobre uma base Ubuntu LTS. O objetivo é fornecer um servidor de impressão moderno, estável, seguro e fácil de implantar.

## 📚 Código-Fonte

Este projeto é de código aberto. O `Dockerfile`, o script de inicialização e o workflow de build do GitHub Actions estão todos disponíveis no repositório do projeto.

➡️ **[Repositório no GitHub: CaTeIM/docker-cups](https://github.com/CaTeIM/docker-cups)**

## ✨ Por que usar esta imagem?

-   ✅ **Estável e Confiável**: Utiliza o método de instalação `apt-get` a partir dos repositórios oficiais do Ubuntu 24.04 LTS, garantindo máxima estabilidade.
-   🔒 **Segura**: O processo de build inclui a aplicação de todas as atualizações de segurança disponíveis (`apt-get upgrade`) e a correção de vulnerabilidades conhecidas em dependências (CVEs).
-   🖨️ **Pronta para Uso**: Inclui um conjunto completo de drivers de impressão (`printer-driver-all`, `hplip`, `openprinting-ppds`), tornando a maioria das impressoras plug-and-play.
-   🚀 **Multi-Arquitetura**: Construída para rodar nativamente em `linux/amd64` (PCs, Servidores Intel/AMD) e `linux/arm64` (Raspberry Pi, Orange Pi 5, etc.).
-   🔧 **Configuração Inteligente**: Possui um script de inicialização que configura um usuário administrador e prepara o CUPS para acesso remoto na primeira execução.

## ⚙️ Como Usar (Exemplo com `docker-compose.yml`)

A forma recomendada de usar esta imagem é com o Portainer Stacks ou `docker-compose`. Crie um arquivo `docker-compose.yml` com o seguinte conteúdo:

```yaml
version: '3.8'

services:
  cups:
    # Use 'latest' ou uma tag de versão específica como '2.4.7'
    image: cateim/cups:latest
    container_name: cups
    # Libera acesso total do container aos dispositivos do sistema
    privileged: true
    # 'host' é a forma mais fácil de garantir a descoberta de impressoras na rede (AirPrint)
    network_mode: host
    restart: unless-stopped
    environment:
      # Defina aqui uma senha segura para o usuário 'admin' da interface web
      - ADMIN_PASSWORD=sua_senha_forte
    volumes:
      # Mapeia a pasta de configuração do CUPS para o seu sistema
      - /srv/cups/config:/etc/cups
      # Mapeia a pasta de logs
      - /srv/cups/logs:/var/log/cups
      # Mapeia a pasta da fila de impressão
      - /srv/cups/spool:/var/spool/cups
      # Essencial para acesso a impressoras conectadas via USB no host
      - /dev/bus/usb:/dev/bus/usb
      # Essencial para descoberta de rede (Avahi)
      - /var/run/dbus:/var/run/dbus
```

### 🔑 Administração

-   Para acessar a interface web, use o endereço: `http://<IP_DO_SEU_SERVIDOR>:631`
-   Para acessar a área de **Administration**, use o login `admin` e a senha que você definiu na variável `ADMIN_PASSWORD`.

---
*Este projeto não é oficialmente afiliado à OpenPrinting. Todo o crédito pelo CUPS vai para seus respectivos desenvolvedores.*
