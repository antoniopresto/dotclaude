# F005: Harness State Visualization - Implementation Plan

> **PAUSED:** Pesquisa de storage realizada. Aguardando aprovação para salvar no harness.

---

## Ações Imediatas (Após Aprovar Plano)

1. **Atualizar `.harness/progress.txt`**
   - Registrar sessão de pesquisa de storage
   - Incluir link para este plano
   - Documentar decisões e próximos passos

2. **Criar F013 em `.harness/features.json`**
   - ID: F013
   - Description: "Storage Architecture Research - Evaluate LanceDB, GraphLite, JSONL sharding for managing external project harness state"
   - Category: research
   - Priority: high
   - Status: backlog
   - passes: false

---

# Pesquisa: Storage Architecture para AI Agents

> **CLARIFICAÇÃO IMPORTANTE:**
> Esta pesquisa é sobre como **HQ (o produto)** vai gerenciar o estado dos **projetos externos**.
> NÃO confundir com o `.harness/` deste repo (que é para desenvolvimento do HQ).
>
> | Conceito | Descrição |
> |----------|-----------|
> | **.harness/ aqui** | Para desenvolver HQ (irrelevante para esta pesquisa) |
> | **HQ como produto** | Vai abrir/gerenciar .harness/ de OUTROS projetos |

## Problema Identificado

Quando HQ gerenciar projetos externos, o `progress.txt` desses projetos pode crescer indefinidamente. Precisamos de uma solução que:

1. **Escale bem** - Não force a AI a ler arquivos enormes
2. **Seja git-friendly** - Funcione bem com versionamento
3. **Permita queries** - A AI possa buscar informação específica sem ler tudo
4. **Suporte conexões** - Idealmente um grafo para relacionamentos semânticos

---

## Opções Pesquisadas (2026-01-04)

### Categoria 1: DBs Embeddados em Rust

| DB | Prós | Contras | Git-Friendly |
|----|------|---------|--------------|
| **[SQLite](https://sqlite.org/)** | Muito estável, arquivo único, SQL | Binário (merge impossível) | ❌ |
| **[Sled](https://github.com/spacejam/sled)** | Pure Rust, lock-free | Usa muito espaço, "unstable" | ❌ |
| **[SurrealDB](https://surrealdb.com/docs/surrealdb/embedding/rust)** | AI-native, multi-modelo | Grande, dependências complexas | ❌ |
| **[RocksDB](https://rocksdb.org/)** | Muito robusto, write-heavy | Dependências não-Rust, grande | ❌ |

### Categoria 2: Graph DBs Embeddados

| DB | Prós | Contras | Git-Friendly |
|----|------|---------|--------------|
| **[GraphLite](https://news.ycombinator.com/item?id=46121076)** | NOVO (Dez 2025), ISO GQL 2024, "SQLite for graphs" | Muito novo | ❌ |
| **[IndraDB](https://github.com/indradb/indradb)** | Pure Rust, suporta sled | Menos features | ❌ |
| **[Cozo](https://lobste.rs/s/gcepzn/cozo_new_graph_db_with_datalog_embedded)** | Datalog, leve como SQLite | Menos popular | ❌ |
| **[GraphRAG-rs](https://github.com/automataIA/graphrag-rs)** | GraphRAG em Rust, WASM suportado | Complexo | ❌ |

### Categoria 3: Vector DBs (RAG/Embeddings)

| DB | Prós | Contras | Git-Friendly |
|----|------|---------|--------------|
| **[LanceDB](https://lancedb.com/)** | Rust core, versioning, petabyte-scale | Arquivos binários | ❌ |
| **Qdrant** | Popular, Docker local | Requer servidor | ❌ |
| **pgvector** | SQL familiar | Requer Postgres | ❌ |

### Categoria 4: Soluções Git-Friendly (Arquivos Texto)

| Solução | Prós | Contras |
|---------|------|---------|
| **[DiffMem](https://github.com/Growth-Kinetics/DiffMem)** | Markdown plaintext, Git-native, histórico no git | Não tem queries SQL |
| **[Beads](https://betterstack.com/community/guides/ai/beads-issue-tracker-ai-agents/)** | SQLite + JSONL companion, merge-friendly | Depende de sync |
| **JSONL Sharding** | Arquivos por sessão/período, human-readable | Implementação manual |

---

## Arquitetura Híbrida Recomendada

Baseado na pesquisa, a melhor abordagem é **híbrida**:

```
┌─────────────────────────────────────────────────────────────┐
│                    .harness/                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  📁 sessions/                   ← JSONL por sessão (git ✓)  │
│     ├── 2026-01-04.jsonl                                    │
│     ├── 2026-01-03.jsonl                                    │
│     └── ...                                                 │
│                                                             │
│  📁 db/                         ← LanceDB (git-ignored)     │
│     └── embeddings.lance        ← Semantic search           │
│                                                             │
│  📄 features.json               ← Status atual (git ✓)      │
│  📄 progress.txt                ← Summary legível (git ✓)   │
│  📄 .gitignore                  ← Ignora db/                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Componentes:

1. **sessions/*.jsonl** (Git-friendly)
   - Um arquivo por sessão/dia
   - Estruturado, mas human-readable
   - AI lê apenas arquivos relevantes

2. **db/embeddings.lance** (Git-ignored)
   - LanceDB para semantic search
   - Rebuilt a partir de JSONL quando necessário
   - Queries rápidas por similaridade

3. **features.json** (Git-friendly)
   - Estado atual das features
   - Pequeno, sempre atualizado

4. **progress.txt** (Git-friendly)
   - Summary legível para humanos
   - Truncado/rotacionado periodicamente

---

## Comandos Tauri Propostos

```rust
// Leitura inteligente (não carrega tudo)
harness_search_sessions(query: String, limit: u32) -> Vec<SessionEntry>
harness_get_recent_sessions(days: u32) -> Vec<SessionSummary>

// Semantic search via LanceDB
harness_semantic_search(query: String, k: u32) -> Vec<RelevantContext>

// Escrita estruturada
harness_log_session_entry(entry: SessionEntry) -> Result<()>
harness_rebuild_embeddings() -> Result<()>  // Reconstrói LanceDB de JSONL
```

---

## Próximos Passos

1. **[ATUAL] Criar tarefa de pesquisa aprofundada** (F013?)
   - Testar LanceDB em Rust
   - Avaliar GraphLite vs LanceDB
   - Prototipar sharding JSONL

2. **Implementar F005 com arquitetura atual**
   - Usar progress.txt/features.json existentes
   - Preparar para migração futura

3. **Migrar para arquitetura híbrida** (F014?)
   - Implementar sessions/*.jsonl
   - Adicionar LanceDB
   - Criar comandos de search

---

## Fontes da Pesquisa

- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [LanceDB Vector Database](https://lancedb.com/)
- [GraphLite - SQLite for Graphs](https://news.ycombinator.com/item?id=46121076)
- [DiffMem - Git-Based Memory](https://github.com/Growth-Kinetics/DiffMem)
- [Beads Issue Tracker](https://betterstack.com/community/guides/ai/beads-issue-tracker-ai-agents/)
- [GraphRAG-rs](https://github.com/automataIA/graphrag-rs)

---

# F005: Implementação Original (Para Depois)

## Overview

**Feature:** Display harness state (progress.txt + features.json) visually
**Priority:** Medium (but user marked as critical)
**Complexity:** Low-Medium
**Estimated Time:** ~2.5 hours

### What This Feature Does

Creates a `ProgressCard` component that shows:
1. **Feature Stats:** X/Y completed with progress bar
2. **Current Session:** Extracted from last SESSION header in progress.txt
3. **Last Commit:** Hash + message from git log
4. **Active Feature:** First feature with `passes: false` highlighted

---

## Implementation Phases

### Phase 1: Rust Backend (3 new commands)

**File:** `src-tauri/src/harness.rs` (NEW)

```rust
// Three Tauri commands:
harness_read_progress(path: String) -> Result<String, String>
harness_read_features(path: String) -> Result<serde_json::Value, String>
harness_get_last_commit(path: String) -> Result<GitCommit, String>
```

**Implementation details:**
- `harness_read_progress`: `std::fs::read_to_string()` on progress.txt
- `harness_read_features`: Read + parse JSON from features.json
- `harness_get_last_commit`: Run `git log -1 --format="%H|%s|%an|%ai"` via `std::process::Command`

**File:** `src-tauri/src/lib.rs` (MODIFY)

```rust
mod harness;  // Add after `mod pty;`

// In invoke_handler, add:
harness::harness_read_progress,
harness::harness_read_features,
harness::harness_get_last_commit,
```

**File:** `src-tauri/src/dev_bridge.rs` (MODIFY)

Add harness commands to `execute_command` match block (~line 283-356).

---

### Phase 2: RPC Layer (TypeScript wrappers)

**File:** `src/lib/rpc.ts` (MODIFY - add after line 341)

```typescript
// === Types ===
export interface GitCommit {
  hash: string;
  message: string;
  author: string;
  date: string;
}

// === Harness Commands ===
export async function harnessReadProgress(path: string): Promise<string> {
  return invoke<string>("harness_read_progress", { path });
}

export async function harnessReadFeatures(path: string): Promise<unknown> {
  return invoke<unknown>("harness_read_features", { path });
}

export async function harnessGetLastCommit(path: string): Promise<GitCommit> {
  return invoke<GitCommit>("harness_get_last_commit", { path });
}
```

---

### Phase 3: ProgressCard Component

**File:** `src/components/ProgressCard.tsx` (NEW)

**Props Interface:**
```typescript
interface ProgressCardProps {
  projectPath: string;
  features: Feature[];
  activeFeatureId?: string | null;
}
```

**PatternFly Components to Use:**
- `Card`, `CardHeader`, `CardBody`, `CardTitle`
- `Progress` (horizontal bar with measureLocation="outside")
- `DescriptionList` (horizontal, compact)
- `Label` (for commit hash, feature ID)
- `Icon` (ClockIcon, CodeBranchIcon, CheckCircleIcon)
- `Skeleton` (loading state)
- `Divider` (visual separation)

**Placement:** Dashboard (main area) - above KanbanBoard, full-width card

**Layout Structure:**
```
+-----------------------------------------------------------------------+
| Harness Progress                                    [Refresh Button] |
+-----------------------------------------------------------------------+
|                                                                       |
|  [Progress Bar: 7/12 completed ================================ 58%]  |
|                                                                       |
|  +------------------------+  +------------------------+               |
|  | Session               |  | Last Commit            |               |
|  | 2026-01-04            |  | fec6772                |               |
|  | F011 Dev Bridge       |  | feat(F011): Dev Bridge |               |
|  +------------------------+  +------------------------+               |
|                                                                       |
+-----------------------------------------------------------------------+
| Active Feature: [F005] Harness state visualization - Display...       |
+-----------------------------------------------------------------------+
```

**File:** `src/components/index.ts` (MODIFY)

```typescript
export { ProgressCard } from './ProgressCard';
```

---

### Phase 4: Integration in App.tsx

**File:** `src/App.tsx` (MODIFY)

1. Import ProgressCard
2. Add ProgressCard in PageSection after the main content area
3. Pass projectPath, features array, and activeFeatureId

---

## Critical Files Summary

| File | Action | Purpose |
|------|--------|---------|
| `src-tauri/src/harness.rs` | CREATE | Rust module with 3 Tauri commands |
| `src-tauri/src/lib.rs` | MODIFY | Register harness module + commands |
| `src-tauri/src/dev_bridge.rs` | MODIFY | Add commands to RPC match block |
| `src/lib/rpc.ts` | MODIFY | Add TypeScript wrappers |
| `src/components/ProgressCard.tsx` | CREATE | Main UI component |
| `src/components/index.ts` | MODIFY | Export ProgressCard |
| `src/App.tsx` | MODIFY | Integrate ProgressCard |

---

## Testing Checklist

- [ ] Rust compiles without errors (`cargo build`)
- [ ] TypeScript compiles without errors (`bun run typecheck`)
- [ ] ProgressCard renders in browser (Playwright MCP screenshot)
- [ ] Progress bar shows correct completed/total
- [ ] Session info extracted from progress.txt
- [ ] Last commit hash + message displayed
- [ ] Active feature highlighted
- [ ] Loading skeleton shows during data fetch
- [ ] Error state displays on RPC failure
- [ ] Console clean (no errors)

---

## Verification Command

```bash
# Start dev server
bun tauri dev

# Visual test with Playwright MCP
mcp__playwright__browser_navigate url="http://localhost:5173"
mcp__playwright__browser_take_screenshot filename="f005-progress-card.png"
mcp__playwright__browser_console_messages level="error"
```

---

## Sources

- [Anthropic: Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [PatternFly Progress Component](https://www.patternfly.org/components/progress/design-guidelines/)
- [PatternFly Card Component](https://pf6.patternfly.org/components/card/)
