# Script de Extração de Conversas Claude Code - MMS Projects

## Objetivo
Criar script Bun/TypeScript para extrair todas as conversas do Claude Code relacionadas a projetos em `~/antonio/mms/*` para uso em:
- Fine-tuning
- Criação de hooks
- Aperfeiçoamento do CLAUDE.md
- Base de conhecimento persistente

## Estrutura Descoberta do Claude Code

### Arquivos Fonte (em `~/.claude/`)
| Localização | Conteúdo |
|-------------|----------|
| `history.jsonl` | Índice de prompts (2103 total, 1112 MMS) |
| `projects/<path>/*.jsonl` | Conversas completas por sessão |
| `debug/*.txt` | Logs de debug/operações |
| `plans/*.md` | Planos gerados |
| `todos/<session>-agent-*.json` | Todos por sessão |

### Formato das Conversas (JSONL)
```typescript
// Mensagem do usuário
{
  type: "user",
  message: { role: "user", content: string },
  sessionId: string,
  uuid: string,
  timestamp: string,
  cwd: string
}

// Resposta do assistente
{
  type: "assistant",
  message: {
    role: "assistant",
    content: [
      { type: "thinking", thinking: string },  // ← PENSAMENTOS!
      { type: "text", text: string },
      { type: "tool_use", name: string, input: object }
    ],
    model: string
  }
}
```

### Projetos MMS Identificados
- `/antonio/mms` (raiz)
- `/antonio/mms/MFC`
- `/antonio/mms/deck`
- `/antonio/mms/system` (598 sessões - projeto atual)
- `/antonio/omms`

## Decisões de Design (Confirmadas)
- **Compressão**: ✅ Gzip (economiza ~70% espaço)
- **Pensamentos**: ✅ Arquivo separado por sessão (`thinking.json.gz`)
- **Debug logs**: ❌ Não incluir (foco nas conversas)

## Estrutura de Saída

```
./genesis/attempt6202/
├── extract.ts           # Script de extração
└── chats/
    ├── mms/
    │   ├── session-<id>/
    │   │   ├── metadata.json.gz     # sessionId, branch, timestamps
    │   │   ├── conversation.json.gz # mensagens ordenadas
    │   │   ├── thinking.json.gz     # pensamentos extraídos (separado)
    │   │   ├── tools.json.gz        # chamadas de ferramentas
    │   │   └── todos.json.gz        # todos da sessão
    │   └── ...
    ├── mms-system/
    │   └── ...
    ├── mms-deck/
    │   └── ...
    └── summary.json                 # estatísticas gerais (sem compressão)
```

## Implementação

### 1. Estrutura do Script (`extract.ts`)
```typescript
// Interfaces
interface Message { type, message, uuid, timestamp, sessionId, cwd }
interface ExtractedConversation {
  metadata,
  messages: { role, content, timestamp, thinking? }[],
  thinking: { timestamp, content }[],
  toolCalls: { name, input, output }[],
  todos: any[]
}

// Funções principais
async function main()
async function findMMSProjects(): string[]
async function loadSessionsForProject(projectPath): SessionInfo[]
async function extractConversation(sessionFile): ExtractedConversation
async function extractThinking(messages): ThinkingEntry[]
async function loadTodos(sessionId): any[]
async function loadDebugLogs(sessionId): string
async function saveExtraction(data, outputPath)
async function generateSummary(extractions): Summary
```

### 2. Passos de Extração
1. Escanear `~/.claude/projects/` por pastas contendo "antonio-mms"
2. Para cada projeto:
   - Listar arquivos .jsonl (sessões)
   - Para cada sessão:
     - Parsear linha por linha (streaming para arquivos grandes)
     - Separar mensagens por tipo
     - Extrair pensamentos (content.type === "thinking")
     - Carregar todos relacionados
     - Salvar em estrutura organizada
3. Gerar summary.json com estatísticas

### 3. Otimizações
- **Streaming**: Usar `Bun.file().text()` com split por linha
- **Deduplicação**: Ignorar file-history-snapshot entries
- **Filtros**: Apenas type: "user" e "assistant"
- **Compressão**: Usar `Bun.gzipSync()` para todos os JSONs
- **Leitura**: `Bun.gunzipSync()` para descomprimir quando necessário

### 4. Compressão com Bun
```typescript
import { gzipSync, gunzipSync } from 'bun';

// Salvar comprimido
async function saveGzipped(data: any, path: string) {
  const json = JSON.stringify(data, null, 2);
  const compressed = gzipSync(Buffer.from(json));
  await Bun.write(path, compressed);
}

// Ler comprimido
async function readGzipped<T>(path: string): Promise<T> {
  const compressed = await Bun.file(path).arrayBuffer();
  const decompressed = gunzipSync(new Uint8Array(compressed));
  return JSON.parse(new TextDecoder().decode(decompressed));
}
```

## Arquivos a Criar/Modificar

| Arquivo | Ação |
|---------|------|
| `./genesis/attempt6202/extract.ts` | CRIAR - Script principal |
| `./genesis/attempt6202/chats/` | CRIAR - Diretório de saída |

## Próximos Passos Após Extração
1. Analisar padrões de erros/alucinações nas conversas
2. Identificar decisões que levaram a falhas
3. Criar hooks preventivos baseados nos padrões
4. Melhorar CLAUDE.md com lições aprendidas

## Comando de Execução
```bash
cd /Users/anotonio.silva/antonio/mms/system
bun run ./genesis/attempt6202/extract.ts
```

## Estimativas
- **Sessões totais**: ~1000+ (598 só em mms-system)
- **Tamanho bruto**: ~500MB-1GB
- **Tamanho comprimido**: ~150-300MB (70% economia)
- **Tempo de execução**: 2-5 minutos

## Checklist de Implementação
- [ ] Criar diretório `./genesis/attempt6202/`
- [ ] Implementar `extract.ts` com interfaces TypeScript
- [ ] Função para escanear projetos MMS
- [ ] Parser JSONL com streaming
- [ ] Extração de pensamentos para arquivo separado
- [ ] Compressão gzip de todos os outputs
- [ ] Geração de summary.json
- [ ] Teste com uma sessão antes de executar em massa
