# Safesign-install.sh

Script em Bash para instalar o **SafeSign IC Standard 3.7.0.0** em **Ubuntu 24.04 (Noble) e derivados**, incluindo todas as dependências legadas necessárias para o funcionamento de tokens Giesecke & Devrient (StarSign CUT S, etc.).

> O objetivo do script é automatizar todo o processo de instalação do SafeSign em sistemas novos, onde várias bibliotecas usadas pelo instalador oficial já não existem mais nos repositórios.

---

## ✅ O que o script faz

1. **Verificações prévias**
   - Confere se o sistema é baseado em Ubuntu.
   - Verifica arquitetura `amd64`.
   - Detecta instalação prévia do SafeSign e pergunta se deve reinstalar.
   - Testa conexão com a internet.
   - Garante espaço mínimo em disco (500 MB).

2. **Instala dependências via APT**
   - `pcscd`, `libccid`, `libpcsclite1`, `libjbig0`
   - `opensc`, `opensc-pkcs11`
   - `libgdk-pixbuf-xlib-2.0-0`, `libgdk-pixbuf2.0-0`
   - `pcsc-tools`, `unrar`

3. **Baixa e instala bibliotecas legadas (do Ubuntu 22.04)**
   Necessárias porque não existem mais no Ubuntu 24.04:
   - `libssl1.1`
   - `libtiff5`
   - `libwxbase3.0-0v5`
   - `libwxgtk3.0-gtk3-0v5`

4. **Baixa e instala o SafeSign**
   - Download do pacote oficial:
     - `SafeSign_IC_Standard_Linux_3.7.0.0_AET.000_ub2004_x86_64.rar`
   - Extração do `.rar`
   - Instalação do `.deb`:
     - `safesignidentityclient`

5. **Configuração final**
   - Habilita e inicia o serviço `pcscd`.
   - Verifica se o pacote `safesignidentityclient` foi instalado.
   - Executa `pcsc_scan` para testar o reconhecimento do token.

---

## 📦 Requisitos

- Sistema baseado em **Ubuntu** (testado em Kubuntu 24.04).
- Arquitetura **amd64**.
- Acesso à internet (para baixar pacotes e dependências).
- Permissões de **sudo**.

---

## 🚀 Como usar

Clone ou baixe este repositório, dê permissão e execute:

```bash
cd ~/Scripts  # ou o diretório onde o script está
chmod +x Safesign-install.sh
./Safesign-install.sh
```

O script é interativo e irá:

- Mostrar as verificações prévias.
- Perguntar se deve reinstalar o SafeSign caso já exista.
- Pedir confirmação antes de iniciar.
- Pedir para conectar o token na etapa de teste com `pcsc_scan`.

---

## 🔍 Testando após a instalação

Depois que o script terminar, você pode testar manualmente:

```bash
# Verificar se o leitor/token é reconhecido
pcsc_scan

# Abrir a ferramenta de administração do token
tokenadmin
```

Se o `pcsc_scan` mostrar seu token e o `tokenadmin` abrir sem erros de biblioteca, a instalação está ok.

---

## ⚠ Avisos

- Este script instala **bibliotecas legadas** (`libssl1.1`, `libtiff5`, wxWidgets 3.0) tiradas de versões antigas do Ubuntu, exclusivamente para compatibilidade com o SafeSign.
- Use por sua conta e risco em ambientes de produção; a ideia é resolver um problema prático em estações de trabalho que dependem de certificados em token.
- Script focado em **Ubuntu 24.04**. Em versões muito diferentes, o comportamento pode variar.

---

## 📄 Licença

Você pode adaptar e reutilizar este script livremente.  
Se publicar modificações, citar a origem ajuda outras pessoas a rastrear melhorias.

---

## 👤 Autor

- **Aurelio** – [`@aureliohff`]([https://github.com/aureliohff](https://github.com/aureliohff), com auxílio da IA _Claude 4.6 Sonnet_.
