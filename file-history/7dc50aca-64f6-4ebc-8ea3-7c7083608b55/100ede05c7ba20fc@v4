# Plano: Harness Runner com PTY (Bun)

## Requisitos (do usuário)

1. **Localização**: `scripts/harness-runner.ts`
2. **Seleção**: Menu inicial para escolher qual harness (root, package-x, etc)
3. **Script npm**: Adicionar `"harness"` no package.json raiz
4. **Automação**: Executar todas tarefas pendentes sequencialmente
5. **Notificações macOS**: Notificação real quando:
   - Claude faz uma pergunta (precisa de input)
   - Todas as tarefas foram concluídas

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│  scripts/harness-runner.ts                                  │
├─────────────────────────────────────────────────────────────┤
│  1. Menu: Escolher harness (root, package-01, etc)          │
│  2. Loop: Para cada feature pendente                        │
│     a. Spawna claude via PTY                                │
│     b. Observa stdout para detectar estados                 │
│     c. Quando tarefa concluída → próxima                    │
│     d. Se pergunta → notifica macOS e aguarda               │
│  3. Fim: Notifica macOS "Todas tarefas concluídas"          │
└─────────────────────────────────────────────────────────────┘
```

## Notificações macOS

```typescript
async function notify(title: string, message: string) {
  await Bun.spawn([
    'osascript', '-e',
    `display notification "${message}" with title "${title}" sound name "Ping"`
  ]);
}

// Uso:
await notify('🤖 Harness', 'Claude precisa de input');
await notify('✅ Harness', 'Todas as tarefas concluídas!');
```

## Detecção de Estados

Observar stdout do Claude para detectar:

| Padrão | Estado | Ação |
|--------|--------|------|
| `╭─` ou prompt vazio por X segundos | Aguardando input | Notificar macOS |
| `git commit` | Tarefa concluída | Próxima tarefa |
| `Error:` | Erro | Notificar + pausar |
| Exit code 0 | Sessão encerrada | Verificar features.json |

## Arquivos a Criar/Modificar

1. **`scripts/harness-runner.ts`** - Runner principal
2. **`scripts/harness-config.ts`** - Configurações dos harnesses
3. **`package.json`** (raiz) - Adicionar script `"harness": "bun scripts/harness-runner.ts"`

## Dependências

```bash
bun add @zenyr/bun-pty
```

## Fluxo do Menu

```
$ bun harness

🔧 MMS Harness Runner
━━━━━━━━━━━━━━━━━━━━━

Selecione o harness:

  1. 🏠 Root (apps/canvas) - 13 pendentes
  2. 📦 harness-orchestrator - 4 pendentes
  3. 📦 harness-dashboard - 32 pendentes

> 1

🚀 Iniciando Root harness...
🎯 Tarefa 1/13: F123 - Minimap navigation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Claude session starts here...]
```

## Fontes

- [Bun.spawn docs](https://bun.sh/docs/api/spawn)
- [@zenyr/bun-pty](https://libraries.io/npm/@zenyr%2Fbun-pty)
- [macOS notifications via osascript](https://developer.apple.com/library/archive/documentation/AppleScript/Conceptual/AppleScriptLangGuide/)
