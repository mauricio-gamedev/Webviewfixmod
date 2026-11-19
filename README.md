# A06 WebCore

Motor Android WebView personalizado baseado no Chromium, com foco inicial no Samsung Galaxy A06 SM-A065M.

Este projeto **não é um navegador**. O objetivo é desenvolver um Android WebView Provider: o componente de renderização e execução web consumido por aplicativos Android que usam `android.webkit.WebView`.

## Motor Chromium

- Dispositivo-alvo: Samsung Galaxy A06 SM-A065M.
- Sistema-alvo: Android 16 / API 36.
- Arquitetura: ARM64 (`arm64-v8a`).
- Linha ativa: **WebView Canary 160.0.8171.0**.
- Outras linhas selecionáveis: Stable M158, Beta M159 e Dev M160.
- Alvo de build: `system_webview_apk`.

Cada canal possui versão, tag e SHA próprios em `project.json`. A sincronização não segue uma branch móvel: ela fixa a revisão exata do canal selecionado. Ainda não existe APK do nosso provedor compilado.

## Selecionar a linha Chromium

```bash
# Canary (padrão)
bash tools/sync_chromium.sh

# Outros canais
CHROMIUM_CHANNEL=stable bash tools/sync_chromium.sh
CHROMIUM_CHANNEL=beta bash tools/sync_chromium.sh
CHROMIUM_CHANNEL=dev bash tools/sync_chromium.sh
```

A mesma variável pode ser usada no build. Canary é a trilha experimental ativa e pode conter regressões; Stable continua disponível para builds de comparação.

## Integração do provedor

- `com.android.webview` é usado pelo modo de teste em imagens AOSP userdebug/eng compatíveis.
- Um firmware AOSP próprio pode integrar `io.github.astromg01.a06webcore` com configuração de provedor e certificado correspondentes.
- O pacote e a assinatura autorizados dependem da configuração de provedor da imagem Android. O projeto não imita certificados Google/Samsung nem contorna validações do sistema.

## Compilar o motor

Leia `AGENTS.md`, `docs/SESSION_CHECKPOINT.md`, `docs/architecture.md`, `docs/provider-integration.md` e `docs/build.md`.

Em um host Linux x86_64 com pelo menos 8 GB de RAM e 100 GB livres (mais de 16 GB de RAM recomendado):

```bash
bash tools/sync_chromium.sh
BUILD_FLAVOR=local-test bash tools/build_webview.sh
```

O Galaxy A06 é o alvo de teste, não o host de compilação. O runner padrão do GitHub Actions não comporta o checkout e o build completos do Chromium.

## Ferramenta auxiliar de diagnóstico

O projeto também inclui o app opcional **A06 WebCore Diagnostics** para medir provedores WebView já instalados e comparar resultados em dispositivo. Esse app não é o motor Chromium, não é navegador, não instala nosso provedor e não é pré-requisito para compilar o WebView personalizado.

Documentação e scripts originais licenciados sob Apache-2.0. O código do Chromium e suas dependências mantêm suas próprias licenças.
