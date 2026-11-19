# A06 WebCore

Motor Android WebView personalizado baseado no Chromium, com foco inicial no Samsung Galaxy A06 SM-A065M.

Este projeto **não é um navegador**. O objetivo é desenvolver um Android WebView Provider: o componente de renderização e execução web consumido por aplicativos Android que usam `android.webkit.WebView`.

O primeiro marco cria a estrutura, a documentação e a validação automatizada. Ainda não contém uma compilação Chromium nem um APK instalável.

Leia `AGENTS.md`, `docs/SESSION_CHECKPOINT.md`, `docs/architecture.md`, `docs/provider-integration.md` e `docs/build.md` antes de alterar a arquitetura.

## Alvo inicial

- Samsung Galaxy A06 SM-A065M
- Android 16
- ARM64 (`arm64-v8a`)
- Sem root; bootloader bloqueado no perfil inicial
- Prioridades: compatibilidade web, estabilidade, segurança e eficiência de memória

## Princípios

- Manter Chromium upstream atualizado e registrar a revisão exata de cada build.
- Não imitar assinaturas Google ou Samsung.
- Não contornar verificação de assinatura nem políticas de segurança do Android.
- Exigir benchmarks reproduzíveis para qualquer otimização.
- Preservar sandbox, isolamento de sites, validação de certificados e atualizações de segurança.

Documentação e scripts originais licenciados sob Apache-2.0. O código do Chromium e suas dependências mantêm suas próprias licenças.