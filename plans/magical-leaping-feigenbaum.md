# Plano: V1.0 Genesis - Research-First SPEC Creation

## A Verdade Fundamental

> **AS PESQUISAS FEITAS SÃO VÁLIDAS, MAS A EXECUÇÃO CONTÉM FALHAS E ALUCINAÇÕES.**

Esta é a **TERCEIRA TENTATIVA**. As anteriores falharam porque:
1. **Perda de contexto/memória** - Compactação de conversa remove constraints críticas
2. **Alucinações na execução** - AI executa código baseado em pesquisas válidas MAS sem memória suficiente, resultando em implementações incorretas
3. **Testes passam mas app não funciona** - Código compila mas não faz o que deveria na prática
4. **Screenshots não representam realidade** - UI aparece "correta" mas lógica está errada
5. **Subagents ignoram constraints** - Decidiram continuar com BlueprintJS apesar das regras

**O problema NÃO é que as pesquisas estavam erradas.**
**O problema É que a execução perdeu contexto e alucinações se acumularam.**

---

## O Objetivo Real

**É:**
1. **REVALIDAR** as pesquisas originais com fontes web atuais (2025/2026)
2. **IDENTIFICAR** onde a execução divergiu das pesquisas (alucinações)
3. **CONSOLIDAR** conhecimento válido + pesquisa web + constraints do usuário
4. **CRIAR** SPEC FINAL baseada em conhecimento verificado
5. **IMPLEMENTAR** com enforcement extremo via hooks

---

## Técnicas do Gemini a Aplicar

### 1. Map-Reduce Cognitivo
```
MAP:     Cada projeto → Extração de conceitos/padrões
REDUCE:  Conceitos → Verificação web → Consolidação
```

### 2. MoE (Mixture of Experts)
Cada agente tem um "chapéu" especializado:
- **EXT-CANVAS**: Expert em rendering/WebGL
- **EXT-DOMAIN**: Expert em railway/ECM/RAMS
- **EXT-SOLVER**: Expert em OR-Tools/CP-SAT
- **VAL-WEB**: Expert em validação com fontes web

### 3. Memória Externa (Hierarquia)

**HARNESS = MEMÓRIA PRINCIPAL** (ponto de entrada obrigatório)
```
.harness/
├── progress.txt      # História de sessões, decisões, contexto
├── features.json     # Estado das tasks, constraints, fases
└── archive/          # Backups de versões anteriores
```

**_migration_memory/ = CONHECIMENTO COLETADO** (complementar)
```
_migration_memory/
├── 00_BRAINSTORMING_*.md   # Ideias dos projetos existentes
├── 10_RESEARCH_*.md        # Pesquisas web validadas
├── 20_CONFLICTS.md         # Divergências identificadas
└── 30_DECISIONS.md         # Decisões finais documentadas
```

**Fluxo de recuperação em QUALQUER sessão:**
```
1. LER .harness/progress.txt     → Entender contexto atual
2. LER .harness/features.json    → Ver fase/task atual
3. LER _migration_memory/*.md    → Conhecimento acumulado
4. CONTINUAR do ponto parado     → Sem perda de progresso
```

**REGRA:** Harness deve ser atualizado a CADA progresso significativo

### 4. Constraint Transformation
| De | Para |
|----|------|
| BlueprintJS | PatternFly v6 |
| @zazcart/tools | @belt/tools |
| React 18 | React 19 |
| useState/useRef | @belt/tools state-machine |
| packages/ monorepo | npm packages direto |

### 5. Tree of Thoughts
Para decisões arquiteturais, explorar múltiplos caminhos:
- Caminho SIMPLES
- Caminho COMPLETO
- Caminho PERFORMANCE

### 6. Ad-hoc RAG via File System
Usar `_migration_memory/` como banco de conhecimento consultável

---

## Sistema de Persistência: HARNESS É O PRINCIPAL

> **O harness é o sistema PRINCIPAL de memória e contexto.**
> **`_migration_memory/` é COMPLEMENTO, não substituto.**

### Hierarquia de Persistência

```
┌─────────────────────────────────────────────────────────────┐
│ NÍVEL 1: HOOKS (Enforcement restritivo)                     │
│ - Executam a cada sessão                                    │
│ - BLOQUEIAM ações proibidas (exit 2)                        │
│ - Sobrevivem compressão, falhas, tudo                       │
│ - São a ÚLTIMA LINHA DE DEFESA                              │
├─────────────────────────────────────────────────────────────┤
│ NÍVEL 2: .harness/features.json (Progresso)                 │
│ - Fonte de verdade para "o que fazer agora"                 │
│ - Cada tarefa com passes: true/false                        │
│ - Agent SEMPRE lê isso primeiro                             │
├─────────────────────────────────────────────────────────────┤
│ NÍVEL 3: .harness/progress.txt (Histórico)                  │
│ - Contexto de sessões anteriores                            │
│ - Decisões tomadas e porquê                                 │
│ - Agent lê para entender contexto                           │
├─────────────────────────────────────────────────────────────┤
│ NÍVEL 4: CLAUDE.md (Regras do Projeto)                      │
│ - Constraints imutáveis                                     │
│ - Stack obrigatório/proibido                                │
│ - Protocolos de trabalho                                    │
├─────────────────────────────────────────────────────────────┤
│ NÍVEL 5: _migration_memory/ (Conhecimento)                  │
│ - Pesquisas e validações                                    │
│ - Decisões arquiteturais                                    │
│ - COMPLEMENTO ao harness                                    │
└─────────────────────────────────────────────────────────────┘
```

### Por que esta hierarquia?

1. **Hooks**: Mesmo que agent alucine, hook BLOQUEIA a ação
2. **features.json**: Mesmo com compressão, agent sabe "próxima tarefa"
3. **progress.txt**: Mesmo em nova sessão, agent entende "onde parou"
4. **CLAUDE.md**: Mesmo sem contexto, agent conhece as regras
5. **_migration_memory/**: Conhecimento detalhado para tarefas específicas

### Princípio de Sobrevivência

> **Se o Claude Code perder TODA a conversa, o agent deve conseguir:**
> 1. Ler hooks → Saber o que NÃO pode fazer
> 2. Ler features.json → Saber a próxima tarefa
> 3. Ler progress.txt → Entender contexto
> 4. Ler CLAUDE.md → Conhecer as regras
> 5. Ler _migration_memory/ → Detalhes específicos

---

## Constraints do Usuário (ÚNICAS VERDADES ABSOLUTAS)

```
!!!! DO NOT CHANGE !!!!
!!!! DO NOT CHANGE !!!!
!!!! DO NOT CHANGE !!!!

✅ USAR:
- React 19
- PatternFly v6
- @belt/tools (npm package)
- Vite (NOT SSR, NOT Next.js)

⛔ NÃO USAR:
- @blueprintjs (QUALQUER versão)
- @zazcart/tools (local toolkit)
- xstate
- next
- useState/useRef/useEffect (usar @belt/tools state-machine)

📦 Estrutura:
- DELETE packages/ folder (no monorepo)
- DELETE apps/canvas/ (recriar do zero)
- Spec target: 3000-4000 lines (consolidated)
```

---

## Fases Revisadas

### FASE 1: COLETA DE IDEIAS (Map Phase do Map-Reduce)

**Contexto crítico para agents:**
> Os 6 projetos contêm pesquisas válidas sobre domain, UX, arquitetura.
> PORÉM: a execução (código) contém alucinações por perda de contexto/memória.
> A tarefa é COLETAR IDEIAS e CONCEITOS, NÃO copiar código.
> Pesquisas documentadas são válidas, mas precisam de VERIFICAÇÃO WEB.

**Tarefas:**

| ID | Tarefa | Contexto para Agent | Output |
|----|--------|---------------------|--------|
| P1-T1 | Scan system/docs/ | "Pesquisas sobre domain (ECM, RAMS, EN 15380) foram feitas com web research válido. Colete os CONCEITOS, não o código. Liste perguntas para verificar." | 01_domain_ideas.md |
| P1-T2 | Scan system/apps/canvas/ | "Arquitetura LOD (Macro/Meso/Micro) foi pesquisada validamente. PORÉM a implementação pode ter alucinações. Colete os PADRÕES descritos, não o código." | 02_canvas_ideas.md |
| P1-T3 | Scan MFC/apps/solver/ | "OR-Tools CP-SAT foi pesquisado validamente. Colete os CONCEITOS matemáticos e padrões, não o código Python." | 03_solver_ideas.md |
| P1-T4 | Scan .harness/ + git log | "Histórico de decisões e erros. CRÍTICO: identifique onde AI alucionou e o que deu errado." | 04_learnings.md |
| P1-T5 | Scan deck/ | "Experimentos com deck.gl. Colete o que funcionou e o que foi abandonado." | 05_alternatives.md |
| P1-T6 | Scan design/ | "Mockups visuais. Extraia padrões de UI/UX, não especificações técnicas." | 06_visual_patterns.md |

**Output consolidado:** `_migration_memory/00_BRAINSTORMING_INPUT.md`
- Lista de conceitos por categoria
- Perguntas específicas para verificar na web
- Pontos onde AI alucionou (do histórico)

### FASE 2: VERIFICAÇÃO WEB (Reduce Phase do Map-Reduce)

**Contexto crítico para agents:**
> As ideias coletadas na Fase 1 são HIPÓTESES baseadas em pesquisas anteriores.
> Agora precisamos VERIFICAR cada hipótese com documentação oficial ATUAL (2025/2026).
> Se a web contradizer as pesquisas anteriores, a web é a fonte de verdade.

**Tarefas:**

| ID | Tópico | Fontes Web Obrigatórias | Objetivo | Output |
|----|--------|-------------------------|----------|--------|
| P2-T1 | PatternFly v6 | patternfly.org, Red Hat docs | Verificar se migração BlueprintJS→PatternFly segue padrões oficiais | 10_patternfly.md |
| P2-T2 | @belt/tools | npm registry, README | Verificar API real do package (não assumir) | 11_belt_tools.md |
| P2-T3 | React 19 state | react.dev official | Por que evitar useState/useRef, padrões recomendados | 12_react19.md |
| P2-T4 | R3F + Vite | r3f docs, three.js | Setup sem SSR, versões compatíveis | 13_r3f_vite.md |
| P2-T5 | Semantic Zoom | Google Earth UX papers, Figma docs | Padrões validados de zoom semântico | 14_semantic_zoom.md |
| P2-T6 | WebGL LOD | three.js LOD docs, perf guides | Performance real, não teórica | 15_webgl_lod.md |
| P2-T7 | Railway domain | EN 15380 specs, ECM guidelines | Terminologia oficial, não inventada | 16_railway.md |
| P2-T8 | OR-Tools | Google OR-Tools docs 2025 | CP-SAT patterns atuais | 17_ortools.md |

### FASE 3: RESOLUÇÃO DE CONFLITOS (Síntese)

**Contexto crítico para agents:**
> Agora temos: (1) Ideias dos projetos, (2) Verificação web, (3) Constraints do usuário.
> A tarefa é COMPARAR e DECIDIR onde cada fonte prevalece.
> Constraints do usuário são LEI ABSOLUTA e nunca cedem.

**Tarefas:**

| ID | Tarefa | Regra de Decisão | Output |
|----|--------|------------------|--------|
| P3-T1 | Comparar ideias vs web | Se web contradiz ideia → web vence | 20_web_overrides.md |
| P3-T2 | Aplicar constraints | Se web contradiz constraint do usuário → constraint vence | 21_constraint_overrides.md |
| P3-T3 | Documentar decisões | Cada decisão com: fonte, razão, alternativas rejeitadas | 22_final_decisions.md |

### FASE 4: SPEC FINAL

**Contexto crítico para agents:**
> A SPEC deve ser escrita baseada APENAS em:
> 1. Conhecimento verificado com web (Fase 2)
> 2. Constraints do usuário (imutáveis)
> 3. Decisões documentadas (Fase 3)
> NÃO copiar código dos projetos antigos.
> NÃO mencionar stack antigo (BlueprintJS, @zazcart, React 18).

**Tarefas:**

| ID | Parte | Conteúdo | Output |
|----|-------|----------|--------|
| P4-T1 | Part I - Domain | Dubai Metro, ECM, RAMS, EN 15380, KPIs | SPECIFICATION.md Part I |
| P4-T2 | Part II - Architecture | React 19 + PatternFly + @belt/tools + R3F | SPECIFICATION.md Part II |
| P4-T3 | Part III - UX | Semantic Zoom, LOD, interactions | SPECIFICATION.md Part III |
| P4-T4 | Part IV - Implementation | Features F001-F020, prioridades | SPECIFICATION.md Part IV |
| P4-T5 | Final Edit | Consolidar ~3000-4000 linhas, remover duplicações | SPECIFICATION.md Final |

### FASE 5: CLEANUP & IMPLEMENTAÇÃO

**Contexto crítico para agents:**
> SOMENTE após SPEC FINAL aprovada pelo usuário.
> O código antigo será DELETADO, não migrado.
> Implementação segue a SPEC, não os projetos antigos.

**Tarefas:**

| ID | Tarefa | Verificação | Gate |
|----|--------|-------------|------|
| P5-T1 | Backup branch | git branch -a mostra backup | - |
| P5-T2 | DELETE packages/ | packages/ não existe | SPEC aprovada |
| P5-T3 | DELETE apps/canvas/ | apps/canvas/ não existe | SPEC aprovada |
| P5-T4 | DELETE docs antigos | docs/ só tem SPECIFICATION.md | SPEC aprovada |
| P5-T5 | Criar estrutura nova | Baseada na SPEC Part II | - |
| P5-T6 | Implementar F001-F020 | Conforme SPEC Part IV | Por feature |

---

## Sistema de Enforcement (6 Camadas)

### Camada 1: SessionStart Hook
**Objetivo:** Mostrar fase atual e constraints a cada sessão

```bash
#!/bin/bash
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 MMS V1.0 GENESIS - RESEARCH-FIRST APPROACH"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ ⚠️  CRITICAL: ALL EXISTING CODE IS BRAINSTORMING INPUT ONLY │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ • Tests passing does NOT mean code works in practice        │"
echo "│ • Screenshots may NOT represent reality                     │"
echo "│ • DEEP WEB RESEARCH is the source of truth                  │"
echo "│ • User constraints are the ONLY absolute rules              │"
echo "└─────────────────────────────────────────────────────────────┘"
echo ""
echo "┌─────────────────────────────────────────────────────────────┐"
echo "│ 🚫 ABSOLUTE CONSTRAINTS (DO NOT VIOLATE)                    │"
echo "├─────────────────────────────────────────────────────────────┤"
echo "│ ✅ USE: React 19, PatternFly v6, @belt/tools, Vite          │"
echo "│ ⛔ NOT: @blueprintjs, @zazcart, xstate, next, React 18      │"
echo "│ ⛔ NOT: useState/useRef/useEffect (use @belt/tools instead) │"
echo "│ ⛔ NOT: packages/ folder (DELETE it)                        │"
echo "│ ⛔ NOT: apps/canvas/ (DELETE and recreate from SPEC)        │"
echo "└─────────────────────────────────────────────────────────────┘"
```

### Camada 2: PreToolUse Bash Hook (NOVO)
**Objetivo:** BLOQUEAR instalação de pacotes proibidos

```bash
#!/bin/bash
# Hook: PreToolUse (Bash) - Exit 2 = BLOCK

COMMAND=$(jq -r '.tool_input.command // empty' 2>/dev/null)
[ -z "$COMMAND" ] && exit 0

FORBIDDEN=("@blueprintjs" "@zazcart" "xstate" "next" "zustand" "redux" "mobx" "react@18" "react@^18")

if [[ "$COMMAND" =~ (bun|npm|yarn|pnpm)[[:space:]]+(add|install|i)[[:space:]] ]]; then
  for pkg in "${FORBIDDEN[@]}"; do
    if [[ "$COMMAND" == *"$pkg"* ]]; then
      echo "🚫 BLOCKED: Forbidden package '$pkg'" >&2
      exit 2
    fi
  done
fi
exit 0
```

### Camada 3: PreToolUse Write/Edit Hook
**Objetivo:** Bloquear edição manual de package.json para adicionar deps proibidas

### Camada 4: PostToolUse Code Hook (NOVO)
**Objetivo:** BLOQUEAR código com imports proibidos

```bash
#!/bin/bash
# Hook: PostToolUse (Write|Edit) - Exit 2 = BLOCK

FILE_PATH=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
CONTENT=$(jq -r '.tool_input.content // empty' 2>/dev/null)
NEW_STRING=$(jq -r '.tool_input.new_string // empty' 2>/dev/null)

[[ "$FILE_PATH" != *.ts && "$FILE_PATH" != *.tsx ]] && exit 0

FORBIDDEN=("from '@blueprintjs" "from '@zazcart" "from 'next/" "from 'xstate")
CHECK="${CONTENT}${NEW_STRING}"

for p in "${FORBIDDEN[@]}"; do
  if [[ "$CHECK" == *"$p"* ]]; then
    echo "🚫 BLOCKED: Forbidden import '$p'" >&2
    exit 2
  fi
done
exit 0
```

### Camada 5: Stop Hook
**Objetivo:** Verificar constraints ao final de cada turno

### Camada 6: CLAUDE.md Reescrito
**Objetivo:** ZERO referências ao stack antigo

---

## Arquivos a Modificar

| # | Arquivo | Ação | Prioridade |
|---|---------|------|------------|
| 1 | `.claude/hooks/session-start.sh` | Reescrever completamente | ALTA |
| 2 | `.claude/hooks/block-forbidden-packages.sh` | CRIAR | ALTA |
| 3 | `.claude/hooks/verify-imports.sh` | CRIAR | ALTA |
| 4 | `.claude/settings.json` | Adicionar novos hooks | ALTA |
| 5 | `CLAUDE.md` | Reescrever (backup primeiro) | ALTA |
| 6 | `.harness/progress.txt` | Corrigir React 18 → 19 | MÉDIA |
| 7 | `.harness/features.json` | Restruturar fases | MÉDIA |

---

## Estrutura do features.json Revisada

```json
{
  "objective": [
    "Consolidate 6 MMS projects into clean V1.0 baseline",
    "Pesquisas originais são VÁLIDAS mas execução contém alucinações",
    "VERIFICAR conceitos com fontes web atuais (2025/2026)",
    "HARNESS é o sistema principal de persistência"
  ],
  "constraints": [
    "!!!! DO NOT CHANGE !!!!",
    "React 19 (NOT React 18)",
    "PatternFly v6 (NOT BlueprintJS)",
    "@belt/tools npm (NOT @zazcart/tools local)",
    "Vite (NOT Next.js, NOT SSR)",
    "Avoid useState/useRef/useEffect (use @belt/tools state-machine)",
    "DELETE packages/ folder (no monorepo)",
    "DELETE apps/canvas/ (recreate from SPEC)",
    "Spec target: 3000-4000 lines consolidated"
  ],
  "phases": [
    {
      "id": "PHASE_1",
      "name": "Coleta de Ideias (Map)",
      "status": "pending",
      "context": "Projetos contêm pesquisas VÁLIDAS mas execução tem alucinações. Coletar CONCEITOS, não código.",
      "tasks": [
        {
          "id": "P1-T1",
          "description": "Scan system/docs/ - coletar conceitos domain (ECM, RAMS, EN 15380)",
          "context": "Pesquisas domain foram feitas com web research válido. Colete CONCEITOS, liste perguntas para verificar.",
          "output": "_migration_memory/01_domain_ideas.md",
          "passes": false
        },
        {
          "id": "P1-T2",
          "description": "Scan system/apps/canvas/ - coletar padrões LOD (Macro/Meso/Micro)",
          "context": "Arquitetura LOD foi pesquisada validamente. PORÉM implementação pode ter alucinações. Colete PADRÕES, não código.",
          "output": "_migration_memory/02_canvas_ideas.md",
          "passes": false
        },
        {
          "id": "P1-T3",
          "description": "Scan MFC/apps/solver/ - coletar conceitos OR-Tools CP-SAT",
          "context": "OR-Tools foi pesquisado validamente. Colete CONCEITOS matemáticos e padrões, não código Python.",
          "output": "_migration_memory/03_solver_ideas.md",
          "passes": false
        },
        {
          "id": "P1-T4",
          "description": "Scan .harness/ + git log - identificar decisões e ERROS",
          "context": "CRÍTICO: identifique onde AI alucionou, o que deu errado, decisões abandonadas.",
          "output": "_migration_memory/04_learnings.md",
          "passes": false
        },
        {
          "id": "P1-T5",
          "description": "Scan deck/ - coletar experimentos e alternativas",
          "context": "Experimentos com deck.gl. Colete o que funcionou e o que foi abandonado.",
          "output": "_migration_memory/05_alternatives.md",
          "passes": false
        },
        {
          "id": "P1-T6",
          "description": "Scan design/ - extrair padrões visuais de mockups",
          "context": "Mockups visuais. Extraia padrões de UI/UX, não especificações técnicas.",
          "output": "_migration_memory/06_visual_patterns.md",
          "passes": false
        },
        {
          "id": "P1-T7",
          "description": "Consolidar em 00_BRAINSTORMING_INPUT.md",
          "context": "Unir todos os outputs em lista de conceitos + perguntas para verificar na web.",
          "output": "_migration_memory/00_BRAINSTORMING_INPUT.md",
          "passes": false
        }
      ]
    },
    {
      "id": "PHASE_2",
      "name": "Verificação Web (Reduce)",
      "status": "pending",
      "context": "Ideias da Fase 1 são HIPÓTESES. VERIFICAR com docs oficiais 2025/2026. Web contradiz pesquisas → web vence.",
      "tasks": [
        {
          "id": "P2-T1",
          "description": "Research PatternFly v6 - migração de BlueprintJS",
          "sources": ["patternfly.org", "Red Hat docs"],
          "output": "_migration_memory/10_patternfly.md",
          "passes": false
        },
        {
          "id": "P2-T2",
          "description": "Research @belt/tools - API real do npm package",
          "sources": ["npm registry", "package README"],
          "output": "_migration_memory/11_belt_tools.md",
          "passes": false
        },
        {
          "id": "P2-T3",
          "description": "Research React 19 - state patterns, por que evitar hooks",
          "sources": ["react.dev official"],
          "output": "_migration_memory/12_react19.md",
          "passes": false
        },
        {
          "id": "P2-T4",
          "description": "Research R3F + Vite - setup sem SSR",
          "sources": ["r3f docs", "three.js docs"],
          "output": "_migration_memory/13_r3f_vite.md",
          "passes": false
        },
        {
          "id": "P2-T5",
          "description": "Research Semantic Zoom - padrões validados",
          "sources": ["Google Earth UX papers", "Figma docs"],
          "output": "_migration_memory/14_semantic_zoom.md",
          "passes": false
        },
        {
          "id": "P2-T6",
          "description": "Research WebGL LOD - performance real",
          "sources": ["three.js LOD docs", "performance guides"],
          "output": "_migration_memory/15_webgl_lod.md",
          "passes": false
        },
        {
          "id": "P2-T7",
          "description": "Research Railway domain - terminologia oficial",
          "sources": ["EN 15380 specs", "ECM guidelines"],
          "output": "_migration_memory/16_railway.md",
          "passes": false
        },
        {
          "id": "P2-T8",
          "description": "Research OR-Tools - CP-SAT patterns 2025",
          "sources": ["Google OR-Tools docs"],
          "output": "_migration_memory/17_ortools.md",
          "passes": false
        }
      ]
    },
    {
      "id": "PHASE_3",
      "name": "Resolução de Conflitos",
      "status": "pending",
      "context": "Comparar: (1) Ideias projetos, (2) Verificação web, (3) Constraints usuário. Constraints são LEI ABSOLUTA.",
      "tasks": [
        {
          "id": "P3-T1",
          "description": "Comparar ideias vs web - documentar onde web override",
          "rule": "Web contradiz ideia → web vence",
          "output": "_migration_memory/20_web_overrides.md",
          "passes": false
        },
        {
          "id": "P3-T2",
          "description": "Aplicar constraints do usuário - documentar overrides",
          "rule": "Web contradiz constraint → constraint vence (LEI ABSOLUTA)",
          "output": "_migration_memory/21_constraint_overrides.md",
          "passes": false
        },
        {
          "id": "P3-T3",
          "description": "Documentar todas as decisões finais",
          "format": "Cada decisão: fonte, razão, alternativas rejeitadas",
          "output": "_migration_memory/22_final_decisions.md",
          "passes": false
        }
      ]
    },
    {
      "id": "PHASE_4",
      "name": "SPEC FINAL",
      "status": "pending",
      "context": "Escrever baseado APENAS em: web verificado + constraints usuário + decisões Fase 3. NÃO copiar código antigo.",
      "tasks": [
        {
          "id": "P4-T1",
          "description": "Write Part I - Domain (Dubai Metro, ECM, RAMS, EN 15380, KPIs)",
          "passes": false
        },
        {
          "id": "P4-T2",
          "description": "Write Part II - Architecture (React 19 + PatternFly + @belt/tools + R3F)",
          "passes": false
        },
        {
          "id": "P4-T3",
          "description": "Write Part III - UX (Semantic Zoom, LOD, interactions)",
          "passes": false
        },
        {
          "id": "P4-T4",
          "description": "Write Part IV - Implementation (Features F001-F020, prioridades)",
          "passes": false
        },
        {
          "id": "P4-T5",
          "description": "Final Edit - Consolidar ~3000-4000 linhas",
          "output": "docs/SPECIFICATION.md",
          "passes": false
        }
      ]
    },
    {
      "id": "PHASE_5",
      "name": "Cleanup & Implementação",
      "status": "pending",
      "context": "SOMENTE após SPEC FINAL aprovada pelo usuário. Código antigo será DELETADO, não migrado.",
      "gate": "SPEC FINAL aprovada",
      "tasks": [
        {
          "id": "P5-T1",
          "description": "Backup branch (backup/pre-v1-YYYYMMDD)",
          "verification": "git branch -a shows backup",
          "passes": false
        },
        {
          "id": "P5-T2",
          "description": "DELETE packages/",
          "verification": "packages/ does not exist",
          "passes": false
        },
        {
          "id": "P5-T3",
          "description": "DELETE apps/canvas/",
          "verification": "apps/canvas/ does not exist",
          "passes": false
        },
        {
          "id": "P5-T4",
          "description": "DELETE docs antigos (keep only SPECIFICATION.md)",
          "verification": "docs/ contains only SPECIFICATION.md",
          "passes": false
        },
        {
          "id": "P5-T5",
          "description": "Create new structure from SPEC Part II",
          "passes": false
        },
        {
          "id": "P5-T6",
          "description": "Implement F001-F020 per SPEC Part IV",
          "passes": false
        }
      ]
    }
  ]
}
```

---

## Checklist de Verificação

### Antes de Qualquer Implementação:
- [ ] Session hook mostra "BRAINSTORMING INPUT ONLY"
- [ ] Session hook mostra "Tests passing does NOT mean code works"
- [ ] Bash hook bloqueia `bun add @blueprintjs`
- [ ] Code hook bloqueia `import from '@blueprintjs'`
- [ ] CLAUDE.md não menciona BlueprintJS, @zazcart, React 18

### Antes de Phase 5 (Cleanup):
- [ ] SPEC FINAL aprovada pelo usuário
- [ ] Todas as pesquisas web documentadas
- [ ] Todas as decisões justificadas com fontes

### Em Cada Sessão:
- [ ] Verificar que NÃO estamos assumindo código antigo como válido
- [ ] Verificar que pesquisa web é a fonte primária
- [ ] Verificar que constraints do usuário são respeitadas

---

## Ordem de Execução

1. **CRIAR** `.claude/hooks/block-forbidden-packages.sh`
2. **CRIAR** `.claude/hooks/verify-imports.sh`
3. **ATUALIZAR** `.claude/hooks/session-start.sh`
4. **ATUALIZAR** `.claude/settings.json`
5. **BACKUP** `CLAUDE.md` → `docs/archive/CLAUDE.md.backup`
6. **REESCREVER** `CLAUDE.md`
7. **ATUALIZAR** `.harness/progress.txt` (React 18 → 19)
8. **ATUALIZAR** `.harness/features.json` (nova estrutura)
9. **COMMIT**

---

## Diferença Fundamental do Plano Anterior

| Antes (ERRADO) | Agora (CORRETO) |
|----------------|-----------------|
| "Extrair conhecimento dos projetos" | "Coletar ideias para brainstorming" |
| "VERIFIED = código executou" | "NADA é verified sem web research" |
| "Usar código existente como base" | "Deletar e recriar do zero" |
| "Tests passing = funciona" | "Tests passing = potencialmente alucinação" |
| "Categorizar como VERIFIED/CLAIMED" | "Tudo é BRAINSTORMING até validar na web" |

---

## O Mantra

> **"BRAINSTORM → RESEARCH → VALIDATE → SPEC → IMPLEMENT"**
>
> Nunca pule o RESEARCH.
> Nunca assuma que código existente funciona.
> Sempre valide com documentação oficial atual.
