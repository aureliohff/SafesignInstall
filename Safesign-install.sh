#!/bin/bash
# ─────────────────────────────────────────────
# Script de instalação do SafeSign IC Standard
# Para Ubuntu 24.04 (Noble) e derivados
# ─────────────────────────────────────────────

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

WORKDIR="$HOME/Downloads/safesign_install"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1

echo -e "${BLUE}═══════════════════════════════════════${NC}"
echo -e "${BLUE}   INSTALAÇÃO DO SAFESIGN IC STANDARD   ${NC}"
echo -e "${BLUE}   Ubuntu 24.04 Noble e derivados       ${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}"

# ── Verificações prévias ──

# 1. Checar se é sistema baseado em Ubuntu
echo -e "\n${YELLOW}[✔] Verificando sistema operacional...${NC}"
if ! grep -qi "ubuntu" /etc/os-release; then
    echo -e "${RED}✗ Este script foi feito para Ubuntu e derivados. Abortando.${NC}"
    exit 1
fi
DISTRO=$(grep "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
echo -e "${GREEN}✓ Sistema compatível: $DISTRO${NC}"

# 2. Checar arquitetura
echo -e "\n${YELLOW}[✔] Verificando arquitetura...${NC}"
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" != "amd64" ]; then
    echo -e "${RED}✗ Este script suporta apenas amd64. Arquitetura detectada: $ARCH. Abortando.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Arquitetura: $ARCH${NC}"

# 3. Checar se SafeSign já está instalado
echo -e "\n${YELLOW}[✔] Verificando instalação existente do SafeSign...${NC}"
if dpkg -l | grep -q safesign; then
    VERSAO_ATUAL=$(dpkg -l | grep safesign | awk '{print $3}')
    echo -e "${YELLOW}⚠ SafeSign já está instalado (versão: $VERSAO_ATUAL).${NC}"
    echo -e "${YELLOW}▸ Deseja reinstalar? (s/N): ${NC}"
    read -r RESPOSTA
    if [[ ! "$RESPOSTA" =~ ^[Ss]$ ]]; then
        echo -e "${GREEN}✓ Instalação cancelada pelo usuário. SafeSign mantido.${NC}"
        exit 0
    fi
    echo -e "${YELLOW}▸ Removendo versão anterior...${NC}"
    sudo dpkg -r safesignidentityclient
fi

# 4. Checar conectividade
echo -e "\n${YELLOW}[✔] Verificando conectividade com a internet...${NC}"
if ! wget -q --spider http://archive.ubuntu.com; then
    echo -e "${RED}✗ Sem acesso à internet. Abortando.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Conexão OK${NC}"

# 5. Checar espaço em disco (mínimo 500MB)
echo -e "\n${YELLOW}[✔] Verificando espaço em disco...${NC}"
ESPACO=$(df "$HOME" --output=avail -m | tail -1)
if [ "$ESPACO" -lt 500 ]; then
    echo -e "${RED}✗ Espaço insuficiente em disco (${ESPACO}MB disponíveis, mínimo 500MB). Abortando.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Espaço disponível: ${ESPACO}MB${NC}"

# ── Confirmação final ──
echo -e "\n${YELLOW}▸ Todas as verificações passaram. Pressione ENTER para iniciar ou Ctrl+C para cancelar...${NC}"
read -r

# ── 1. Dependências nativas do apt ──
echo -e "\n${YELLOW}[1/6] Instalando dependências via apt...${NC}"
sudo apt update
sudo apt install -y \
    pcscd \
    libccid \
    libjbig0 \
    libpcsclite1 \
    opensc \
    opensc-pkcs11 \
    libgdk-pixbuf-xlib-2.0-0 \
    libgdk-pixbuf2.0-0 \
    pcsc-tools \
    unrar

# ── 2. Dependências legadas (removidas no Ubuntu 24.04) ──
echo -e "\n${YELLOW}[2/6] Baixando dependências legadas do Ubuntu 22.04...${NC}"
wget -q --show-progress \
    "http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2_amd64.deb" \
    "http://archive.ubuntu.com/ubuntu/pool/main/t/tiff/libtiff5_4.3.0-6_amd64.deb" \
    "http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxbase3.0-0v5_3.0.5.1+dfsg-4_amd64.deb" \
    "http://archive.ubuntu.com/ubuntu/pool/universe/w/wxwidgets3.0/libwxgtk3.0-gtk3-0v5_3.0.5.1+dfsg-4_amd64.deb"

# ── 3. Instalar dependências legadas na ordem correta ──
echo -e "\n${YELLOW}[3/6] Instalando dependências legadas...${NC}"
sudo dpkg -i libssl1.1_1.1.1f-1ubuntu2_amd64.deb
sudo dpkg -i libtiff5_4.3.0-6_amd64.deb
sudo dpkg -i libwxbase3.0-0v5_3.0.5.1+dfsg-4_amd64.deb
sudo dpkg -i libwxgtk3.0-gtk3-0v5_3.0.5.1+dfsg-4_amd64.deb

# ── 4. Baixar e extrair o SafeSign ──
echo -e "\n${YELLOW}[4/6] Baixando SafeSign IC Standard 3.7.0.0...${NC}"
wget -q --show-progress \
    "https://safesign.gdamericadosul.com.br/content/SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.rar"

echo -e "\n${YELLOW}[5/6] Extraindo pacote...${NC}"
unrar e SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.rar

# ── 5. Instalar o SafeSign ──
echo -e "\n${YELLOW}[6/6] Instalando SafeSign...${NC}"
sudo dpkg -i SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.deb
sudo apt install -f -y

# ── 6. Habilitar e iniciar o pcscd ──
echo -e "\n${YELLOW}[+] Habilitando serviço pcscd...${NC}"
sudo systemctl enable pcscd
sudo systemctl start pcscd

# ── Verificação final ──
echo -e "\n${YELLOW}[+] Verificando instalação...${NC}"
if dpkg -l | grep -q safesign; then
    VERSAO=$(dpkg -l | grep safesign | awk '{print $3}')
    echo -e "${GREEN}✓ SafeSign $VERSAO instalado com sucesso!${NC}"
else
    echo -e "${RED}✗ Algo deu errado na instalação. Verifique os logs acima.${NC}"
    exit 1
fi

echo -e "\n${YELLOW}[+] Testando reconhecimento do token (conecte o token USB agora)...${NC}"
echo -e "${YELLOW}▸ Pressione ENTER quando o token estiver conectado...${NC}"
read -r
pcsc_scan -r

echo -e "\n${BLUE}═══════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Instalação concluída!${NC}"
echo -e "${YELLOW}▸ Execute 'tokenadmin' para gerenciar o token.${NC}"
echo -e "${BLUE}═══════════════════════════════════════${NC}\n"
