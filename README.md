# A06 WebCore

Motor Android WebView personalizado baseado no Chromium, com foco inicial no Samsung Galaxy A06 SM-A065M.

Este projeto **não é um navegador**. O objetivo é desenvolver um Android WebView Provider: o componente de renderização e execução web consumido por aplicativos Android que usam `android.webkit.WebView`.

## Baseline atual

- Dispositivo-alvo: Samsung Galaxy A06 SM-A065M.
- Sistema-alvo: Android 16 / API 36.
- Arquitetura: ARM64 (`arm64-v8a`).
- Chromium: WebView Stable 158.0.8127.36.
- Revisão: `14d6f648e8cd7ad750a4044200ce94d3321be260`.
- Alvo de build: `system_webview_apk`.

A revisão está fixada para tornar os builds reproduzíveis. Ainda não existe APK compilado neste repositório.

## Importante sobre instalação

- `com.android.webview` é usado pelo modo de teste em imagens AOSP userdebug/eng compatíveis.
- Um firmware AOSP próprio pode integrar `io.github.astromg01.a06webcore` com configuração de provedor e certificado correspondentes.
- Em firmware Samsung de varejo com GMS, os nomes de pacote e certificados de provedor são controlados pelo sistema. Um APK assinado por nós não substitui o WebView Google/Samsung no aparelho original bloqueado.

## Começar

Leia `AGENTS.md`, `docs/SESSION_CHECKPOINT.md`, `docs/architecture.md`, `docs/provider-integration.md` e `docs/build.md`.

Em um host Linux x86_64 preparado para builds Chromium:

```bash
tools/sync_chromium.sh
BUILD_FLAVOR=local-test tools/build_webview.sh
```

A compilação Chromium exige um ambiente Linux x86_64 com bastante RAM e armazenamento. O Galaxy A06 é alvo de teste, não host de compilação.

## Princípios

- Manter Chromium upstream atualizado e registrar a revisão exata de cada build.
- Não imitar assinaturas Google ou Samsung.
- Não contornar verificação de assinatura nem políticas de segurança do Android.
- Exigir benchmarks reproduzíveis para qualquer otimização.
- Preservar sandbox, isolamento de sites, validação de certificados e atualizações de segurança.

Documentação e scripts originais licenciados sob Apache-2.0. O código do Chromium e suas dependências mantêm suas próprias licenças.
