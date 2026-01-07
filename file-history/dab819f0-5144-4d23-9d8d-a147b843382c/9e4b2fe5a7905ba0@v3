# Harness Dashboard - Plano de Implementação

## Visão Geral

**Projeto:** Interface web para gerenciar múltiplas instâncias do Claude Code
**Stack:** Astro 5 + React 19 + shadcn/ui 2 + Tailwind + MongoDB local + WebSocket
**Localização:** `packages/harness-dashboard/`

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────────────────┐
│                         FRONTEND (Astro + React)                     │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────┐  ┌──────────────┐  ┌────────────┐  ┌──────────────┐  │
│  │  Kanban  │  │  Chat (Slack │  │   Graph    │  │ Debug Panel  │  │
│  │  Board   │  │    style)    │  │  (deps)    │  │ (terminals)  │  │
│  └──────────┘  └──────────────┘  └────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              │ WebSocket
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         BACKEND (Bun + Hono)                         │
├─────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────────┐  │
│  │ Agent Pool   │  │ State Manager│  │ WebSocket Server         │  │
│  │ (spawn CLI)  │  │ (MongoDB)    │  │ (real-time events)       │  │
│  └──────────────┘  └──────────────┘  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         AGENTS (Claude Code CLI)                     │
├─────────────────────────────────────────────────────────────────────┤
│  agents/                                                             │
│  ├── project-manager/    ← Agente gerente (dispatch outros)         │
│  │   ├── CLAUDE.md                                                  │
│  │   └── .claude/                                                   │
│  ├── frontend-dev/       ← Especialista React/UI                    │
│  ├── backend-dev/        ← Especialista Node/DB                     │
│  └── qa-tester/          ← Especialista em testes                   │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Features (24 features em 5 fases)

### Fase 0: Setup (D001-D004)

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D001 | Package init: Astro 5 + React 19 + Tailwind + shadcn/ui 2 | - |
| D002 | MongoDB connection (native driver) + schemas (@mms/toolkit) | D001 |
| D003 | WebSocket server (ws) + event types | D001 |
| D004 | Estrutura de agents (pastas, CLAUDE.md template) | D001 |

### Fase 1: Core Backend (D005-D008)

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D005 | Agent spawner (spawn Claude CLI em dir específico) | D003, D004 |
| D006 | Event bridge (agent stdout → WebSocket → frontend) | D003, D005 |
| D007 | Harness state (MongoDB-backed, substitui features.json) | D002 |
| D008 | Dependency graph (reusar do orchestrator) | D007 |

### Fase 2: Dashboard UI (D009-D012)

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D009 | Layout shell (sidebar, main area, resizable debug panel) | D001 |
| D010 | Agent list (status: idle/busy, avatar, current task) | D006, D009 |
| D011 | Chat interface (Slack-style, agents como "pessoas") | D009, D010 |
| D012 | Debug panel (terminal output por agent, tabs) | D006, D009 |

### Fase 3: Task Management (D013-D016)

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D013 | Kanban board (drag-drop, colunas: backlog/ready/running/done) | D007, D009 |
| D014 | Dependency graph view (react-flow, nodes = tasks) | D008, D009 |
| D015 | Critical path highlighting (visual emphasis) | D008, D014 |
| D016 | Parallel execution indicators (which tasks can run together) | D008, D013 |

### Fase 4: AI Integration (D017-D020)

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D017 | Project Manager agent (CLAUDE.md + capabilities) | D004, D005 |
| D018 | Dispatch agents from UI (button → spawn agent on task) | D005, D013 |
| D019 | Auto-planning (PM agent analisa e cria tasks) | D007, D017 |
| D020 | Quality review (verificar output antes de marcar done) | D017, D018 |

### Fase 5: Polish (D021-D024)

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D021 | Multi-project support (switch entre projetos) | D007 |
| D022 | Session history viewer (logs de todas sessões) | D007, D011 |
| D023 | Cost tracking dashboard (tokens, modelo, $$$) | D006, D009 |
| D024 | Export/import (backup/restore projetos) | D007, D021 |

---

## Decisões Técnicas

### 1. Por que Astro + React (não só React)?
- Astro: SSG para páginas estáticas, islands para interatividade
- Melhor performance inicial
- shadcn/ui funciona perfeitamente com React islands

### 2. Por que Hono (não Express)?
- Mais leve e moderno
- TypeScript-first
- Funciona com Bun nativamente
- WebSocket support built-in

### 3. Por que MongoDB nativo (não Mongoose)?
- User request: "mongoose é bem ruim"
- Usar @mms/toolkit schema para validação
- Driver nativo é mais simples e performático

### 4. Por que react-flow para dependências?
- Melhor visualização de grafos
- Nodes arrastáveis
- Zoom/pan nativo
- Muito usado em ferramentas de workflow

### 5. Chat UI vs Terminal output
- Chat: mensagens de alto nível ("Comecei a task X", "Terminei Y")
- Debug panel: output raw do terminal (stdout/stderr completo)
- Separação clara entre comunicação e debug

---

## Estrutura de Diretórios

```
packages/harness-dashboard/
├── CLAUDE.md                 # Instruções para este projeto
├── features.json             # Harness do próprio projeto
├── progress.txt              # Log de sessões
├── package.json
├── tsconfig.json
├── astro.config.mjs
├── tailwind.config.js
│
├── src/
│   ├── components/           # React components (shadcn/ui)
│   │   ├── ui/              # shadcn primitives
│   │   ├── chat/            # Chat interface
│   │   ├── kanban/          # Kanban board
│   │   ├── graph/           # Dependency graph
│   │   └── debug/           # Debug panel
│   │
│   ├── layouts/
│   │   └── Dashboard.astro   # Main layout
│   │
│   ├── pages/
│   │   ├── index.astro       # Dashboard principal
│   │   ├── projects/         # Multi-project views
│   │   └── api/              # API routes (Astro endpoints)
│   │
│   ├── server/               # Backend logic
│   │   ├── db/              # MongoDB connection + schemas
│   │   ├── agents/          # Agent spawner
│   │   ├── ws/              # WebSocket server
│   │   └── harness/         # State manager
│   │
│   └── lib/                  # Shared utilities
│       ├── types.ts
│       └── constants.ts
│
├── agents/                   # Agent directories (cada um isolado)
│   ├── project-manager/
│   │   ├── CLAUDE.md
│   │   └── .claude/
│   ├── frontend-dev/
│   ├── backend-dev/
│   └── qa-tester/
│
└── public/
    └── avatars/              # Agent avatars
```

---

## MongoDB Collections

```typescript
// projects
{
  _id: ObjectId,
  name: string,
  description: string,
  createdAt: Date,
  updatedAt: Date,
  settings: {
    maxAgents: number,
    defaultModel: string
  }
}

// features (= tasks no harness)
{
  _id: ObjectId,
  projectId: ObjectId,
  featureId: string,         // "D001", "D002"
  category: string,
  priority: number,
  description: string,
  steps: string[],
  passes: boolean,
  blockedBy: string[],
  notes: string,
  status: 'backlog' | 'ready' | 'running' | 'done' | 'failed',
  assignedAgent: string | null,
  startedAt: Date | null,
  completedAt: Date | null
}

// sessions
{
  _id: ObjectId,
  projectId: ObjectId,
  featureId: string,
  agentId: string,
  startedAt: Date,
  endedAt: Date | null,
  status: 'running' | 'completed' | 'failed',
  logs: [{
    timestamp: Date,
    type: 'stdout' | 'stderr' | 'system',
    content: string
  }],
  tokenUsage: {
    input: number,
    output: number
  },
  cost: number
}

// messages (chat)
{
  _id: ObjectId,
  projectId: ObjectId,
  sessionId: ObjectId | null,
  agentId: string,           // 'project-manager', 'frontend-dev', 'system'
  type: 'message' | 'status' | 'error',
  content: string,
  timestamp: Date
}
```

---

## Libs Externas (estáveis, de grandes empresas)

| Lib | Versão | Propósito | Mantido por |
|-----|--------|-----------|-------------|
| astro | 5.x | Framework | Astro (Vercel backed) |
| react | 19.x | UI | Meta |
| tailwindcss | 4.x | Styling | Tailwind Labs |
| @radix-ui/* | latest | Primitives | WorkOS |
| react-flow | 11.x | Graph viz | xyflow |
| @tanstack/react-query | 5.x | Data fetching | TanStack |
| mongodb | 6.x | DB driver | MongoDB Inc |
| ws | 8.x | WebSocket | npm core |
| hono | 4.x | HTTP server | Cloudflare |
| zod | 3.x | Validation | Colin McDonnell |

---

## Próximos Passos

1. Criar estrutura do package com harness
2. Implementar D001 (setup básico)
3. Seguir o harness protocol para cada feature

---

---

## Anti-Go-Horse Protocol (AGPH)

### O Problema
Agents AI tendem a entrar em loops tentando resolver erros:
```
Erro → Tenta fix 1 → Falha → Tenta fix 2 → Falha → Tenta fix 3...
```
Isso consome contexto, tempo e dinheiro sem resolver o problema.

### A Solução: AGPH Hook

Um hook que monitora o comportamento do agent e força paradas inteligentes:

```bash
# .claude/hooks/anti-go-horse.sh
# Triggered: PostToolUse (após cada ação)

# Detecta padrões de loop:
# 1. Mesmo erro 2+ vezes
# 2. Mesmo arquivo editado 3+ vezes sem sucesso
# 3. Build/test falhando 3+ vezes seguidas

# Ações escalonadas:
# Nível 1: PAUSE + mostrar últimos 5 passos
# Nível 2: SEARCH + buscar solução na web
# Nível 3: ESCALATE + pedir ajuda (spawn outro agent)
# Nível 4: STOP + notificar humano
```

### Implementação via Hook

```python
#!/usr/bin/env python3
# .claude/hooks/anti-go-horse.py

import json
import sys
from pathlib import Path

# Estado persistente entre chamadas
STATE_FILE = Path(".claude/agph-state.json")

def load_state():
    if STATE_FILE.exists():
        return json.loads(STATE_FILE.read_text())
    return {"errors": [], "edits": {}, "failures": 0}

def save_state(state):
    STATE_FILE.write_text(json.dumps(state, indent=2))

def detect_loop(state, current_action):
    # Mesmo erro repetido?
    if current_action.get("error"):
        error_sig = current_action["error"][:100]
        if state["errors"].count(error_sig) >= 2:
            return "error_loop"
        state["errors"].append(error_sig)

    # Mesmo arquivo editado muitas vezes?
    if current_action.get("file"):
        file = current_action["file"]
        state["edits"][file] = state["edits"].get(file, 0) + 1
        if state["edits"][file] >= 3:
            return "edit_loop"

    # Build/test falhando repetidamente?
    if current_action.get("command") in ["build", "test", "typecheck"]:
        if current_action.get("failed"):
            state["failures"] += 1
            if state["failures"] >= 3:
                return "failure_loop"
        else:
            state["failures"] = 0

    return None

def get_remedy(loop_type, state):
    if loop_type == "error_loop":
        return {
            "action": "SEARCH",
            "message": "🔴 AGPH: Mesmo erro detectado 2+ vezes. PARE e pesquise:\n"
                      f"WebSearch: '{state['errors'][-1][:50]} solution 2025'"
        }
    elif loop_type == "edit_loop":
        return {
            "action": "REVIEW",
            "message": "🟡 AGPH: Arquivo editado 3+ vezes. PARE e revise:\n"
                      "1. Leia o arquivo inteiro\n"
                      "2. Entenda o contexto\n"
                      "3. Planeje antes de editar"
        }
    elif loop_type == "failure_loop":
        return {
            "action": "ESCALATE",
            "message": "🟠 AGPH: Build/test falhando 3+ vezes. Opções:\n"
                      "1. WebSearch pelo erro específico\n"
                      "2. Ler documentação oficial\n"
                      "3. Pedir ajuda via spawn de outro agent"
        }
    return None

# Main hook logic
if __name__ == "__main__":
    hook_data = json.loads(sys.stdin.read())
    state = load_state()

    loop_type = detect_loop(state, hook_data)
    if loop_type:
        remedy = get_remedy(loop_type, state)
        print(remedy["message"])
        # Reset state após intervenção
        state = {"errors": [], "edits": {}, "failures": 0}

    save_state(state)
```

### Níveis de Escalação

| Nível | Trigger | Ação | Resultado |
|-------|---------|------|-----------|
| 1 | Erro repetido 2x | PAUSE | Mostrar contexto, sugerir revisão |
| 2 | Edit loop 3x | SEARCH | Forçar WebSearch antes de continuar |
| 3 | Failure 3x | ESCALATE | Opções: web, docs, ou spawn helper |
| 4 | Nenhuma solução | STOP | Notificar humano, pausar agent |

### Integração com Dashboard

O AGPH se integra com o dashboard:
- **UI mostra**: Status do AGPH (verde/amarelo/vermelho)
- **Histórico**: Quantos loops detectados/evitados
- **Métricas**: Economia de tokens por intervenções
- **Override**: Humano pode desativar para task específica

---

## Harness Parity (Paridade Completa)

### Requisito
Tudo que o harness de arquivos faz deve ser possível e **auditável** via UI.

### Mapeamento Arquivo → UI

| Arquivo | Funcionalidade | UI Equivalente |
|---------|----------------|----------------|
| `features.json` | Lista de features | Kanban Board |
| `features.json` | Status (passes) | Checkmarks visuais |
| `features.json` | blockedBy | Graph de dependências |
| `features.json` | priority | Ordenação drag-drop |
| `progress.txt` | Histórico sessões | Timeline view |
| `progress.txt` | Decisões/notas | Comment threads |
| `CLAUDE.md` | Instruções agent | Agent config panel |
| `.claude/hooks/` | Enforcement | Hook editor + logs |
| `.claude/settings.json` | Permissões | Permission matrix |

### Features Adicionais para Parity

Adicionando à lista de features:

| ID | Descrição | Fase |
|----|-----------|------|
| D025 | Timeline view (histórico de sessões) | Parity |
| D026 | Comment threads em features | Parity |
| D027 | Agent config editor (CLAUDE.md via UI) | Parity |
| D028 | Hook editor + execution logs | Parity |
| D029 | Permission matrix (deny rules) | Parity |
| D030 | AGPH status + metrics | AGPH |
| D031 | AGPH override controls | AGPH |
| D032 | Diff viewer (mudanças por sessão) | Parity |

### Auditoria

Toda ação é logada e visível:

```typescript
// audit_logs collection
{
  _id: ObjectId,
  projectId: ObjectId,
  timestamp: Date,
  actor: 'agent' | 'human' | 'system',
  actorId: string,
  action: string,          // 'feature.update', 'agent.spawn', 'agph.trigger'
  target: string,          // 'D001', 'project-manager'
  before: object | null,   // Estado anterior
  after: object | null,    // Estado posterior
  metadata: object         // Contexto adicional
}
```

UI de auditoria:
- **Activity feed**: Timeline de todas ações
- **Filtros**: Por agent, feature, tipo de ação
- **Diff view**: Antes/depois para cada mudança
- **Export**: CSV/JSON para análise externa

---

## Features Atualizadas (32 features)

### Fase 0: Setup (D001-D004) - 4 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D001 | Package init: Astro 5 + React 19 + Tailwind + shadcn/ui 2 | - |
| D002 | MongoDB connection (native driver) + schemas (@mms/toolkit) | D001 |
| D003 | WebSocket server (ws) + event types | D001 |
| D004 | Estrutura de agents (pastas, CLAUDE.md template) | D001 |

### Fase 1: Core Backend (D005-D008) - 4 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D005 | Agent spawner (spawn Claude CLI em dir específico) | D003, D004 |
| D006 | Event bridge (agent stdout → WebSocket → frontend) | D003, D005 |
| D007 | Harness state (MongoDB-backed, substitui features.json) | D002 |
| D008 | Dependency graph (reusar do orchestrator) | D007 |

### Fase 2: Dashboard UI (D009-D012) - 4 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D009 | Layout shell (sidebar, main area, resizable debug panel) | D001 |
| D010 | Agent list (status: idle/busy, avatar, current task) | D006, D009 |
| D011 | Chat interface (Slack-style, agents como "pessoas") | D009, D010 |
| D012 | Debug panel (terminal output por agent, tabs) | D006, D009 |

### Fase 3: Task Management (D013-D016) - 4 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D013 | Kanban board (drag-drop, colunas: backlog/ready/running/done) | D007, D009 |
| D014 | Dependency graph view (react-flow, nodes = tasks) | D008, D009 |
| D015 | Critical path highlighting (visual emphasis) | D008, D014 |
| D016 | Parallel execution indicators (which tasks can run together) | D008, D013 |

### Fase 4: AI Integration (D017-D020) - 4 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D017 | Project Manager agent (CLAUDE.md + capabilities) | D004, D005 |
| D018 | Dispatch agents from UI (button → spawn agent on task) | D005, D013 |
| D019 | Auto-planning (PM agent analisa e cria tasks) | D007, D017 |
| D020 | Quality review (verificar output antes de marcar done) | D017, D018 |

### Fase 5: Polish (D021-D024) - 4 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D021 | Multi-project support (switch entre projetos) | D007 |
| D022 | Session history viewer (logs de todas sessões) | D007, D011 |
| D023 | Cost tracking dashboard (tokens, modelo, $$$) | D006, D009 |
| D024 | Export/import (backup/restore projetos) | D007, D021 |

### Fase 6: Harness Parity (D025-D029) - 5 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D025 | Timeline view (histórico visual de sessões) | D022 |
| D026 | Comment threads em features (discussão contextual) | D013 |
| D027 | Agent config editor (editar CLAUDE.md via UI) | D010, D017 |
| D028 | Hook editor + execution logs (ver/editar hooks) | D005 |
| D029 | Permission matrix (visualizar/editar deny rules) | D027 |

### Fase 7: Anti-Go-Horse (D030-D032) - 3 features

| ID | Descrição | Blocked By |
|----|-----------|------------|
| D030 | AGPH detector hook (Python, detecta loops) | D005 |
| D031 | AGPH UI (status, métricas, histórico intervenções) | D009, D030 |
| D032 | AGPH override controls (desativar para task específica) | D031 |

---

---

## Self-Hosting Harness (Meta)

This project uses its own harness during development. The building agent follows the same protocol it's building.

### Harness Files (at package root)

```
packages/harness-dashboard/
├── CLAUDE.md              # Instructions for building agent (temporary)
├── features.json          # 32 features (D001-D032)
├── progress.txt           # Session history
├── .claude/
│   ├── settings.json      # Hook registration
│   ├── settings.local.json # Deny permissions
│   └── hooks/
│       ├── session-start.sh        # Print harness intro
│       ├── anti-go-horse.py        # AGPH detector
│       ├── protect-package-json.sh # Block manual edits
│       └── end-of-turn-check.sh    # Quality gate
```

### AGPH for Building Agent

The agent building this project MUST follow AGPH:
- Same error 2x → STOP + WebSearch
- Same file edited 3x → STOP + Review context
- Build/test fails 3x → STOP + Escalate (research or spawn helper)

---

## Notes

- **CLAUDE.md at root**: Temporary, for building agent (will be moved to agents/ later)
- **Each production agent isolated**: Own CLAUDE.md and .claude/
- **Use @mms/toolkit**: Schema, state-machine, utils
- **MongoDB no password**: Local development only
- **WebSocket for everything**: Real-time first
- **AGPH mandatory**: All agents (including builder) use anti-go-horse hook
- **Full audit trail**: Every action logged and visible in UI
