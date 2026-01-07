# Plano: Sistema de QA Visual com Agentes Comunicando via Tickets

**Data:** 2025-12-13
**OS:** macOS Darwin 25.1.0
**Contexto:** Usuário com COVID, precisa de máxima autonomia da AI

---

## Checklist de Problemas (urgent-problems.txt)

| # | Problema | Solução | Fase |
|---|----------|---------|------|
| 1.1 | Blind AI | QA Agent + Playwright MCP | Fase 2 |
| 1.2 | Context Loss | `insights.md` + tickets persistentes | Fase 2 |
| 1.3 | Code Quality | Lint obrigatório + PR review via ticket | Fase 2 |
| 1.4 | Process Failure | Critérios visuais verificáveis | Fase 2 |
| 2.1 | Blue Screen | **FIX IMEDIATO:** loader.ts notify store | Fase 0 |
| 2.2 | State Sync Failure | **FIX IMEDIATO:** loader.ts | Fase 0 |
| 2.3 | Missing QA | QA Agent | Fase 2 |
| 3.1 | Complex Requirements | Tickets + features.json | Fase 2 |
| 3.2 | Urgency | Fase 0 primeiro, depois sistema robusto | Fase 0-2 |
| 3.3 | User Constraint | Máxima autonomia, mínima intervenção | Todas |
| 4.1 | UX/Psychology | Fase futura | Fase 3+ |
| 4.2 | QA Gap | QA Agent | Fase 2 |

---

## O Problema Identificado

**Sintoma:** Humano vê tela azul, mas todos os testes passam e AI acha que está OK.

**Causa Raiz:**
1. `features.json` marca `render-003: LOD 1: Instanced Mesh for Bars` como "done" e "passes: true"
2. Mas NADA está sendo renderizado visualmente
3. A AI não tem mecanismo para VER e ENTENDER o que está na tela
4. Os testes E2E verificam apenas "canvas exists", não "conteúdo correto renderizado"
5. O snapshot visual foi capturado de tela azul → compara azul com azul → passa

**O que deveria estar visível (baseado em features.json + PROJECT.md):**
- 128 trens × 12 anos de schedule
- Barras coloridas por tipo de manutenção (PM=verde, Overhaul=laranja, etc.)
- Sistema LOD funcionando (heatmap/bars/capsules dependendo do zoom)

---

## Entendimento do Que o Usuário Quer

### Sistema de Dois Agentes Separados:

1. **Developer Agent** (Especialista)
   - Implementa features
   - Trabalha no código
   - Quando termina uma tarefa, cria um TICKET para QA

2. **QA Agent** (Quality Assurance)
   - Recebe tickets do Developer
   - Usa Playwright MCP para VER a tela como humano
   - Lê features.json para saber o que DEVERIA estar visível
   - Compara visual real vs esperado
   - Aprova ou rejeita com feedback específico

### Comunicação via Tickets (inspirado no Harness):
- Não compartilham contexto/memória diretamente
- Comunicação assíncrona e persistente
- Rastreável a longo prazo
- Funciona em projetos complexos

### Critérios de Aceitação Visual:
Para cada feature visual em features.json, deve haver critérios mensuráveis:
```json
{
  "id": "render-003",
  "name": "LOD 1: Instanced Mesh for Bars",
  "status": "done",
  "visualCriteria": {
    "minVisibleBlocks": 100,
    "expectedColors": ["#3ddc84", "#ff6b35", "#4ecdc4"],
    "canvasNotUniform": true,
    "description": "Barras coloridas visíveis representando blocos de manutenção"
  }
}
```

### Ambiente Sempre Conhecido:
- Data atual: 2025-12-13
- OS: macOS Darwin 25.1.0
- Isso deve estar no CLAUDE.md ou init.sh output

---

## Plano de Implementação

### Fase 1: Criar Sistema de Tickets

**Arquivo:** `qa-tickets/` directory

Estrutura:
```
qa-tickets/
├── pending/          # Tickets aguardando QA
├── approved/         # Tickets aprovados
├── rejected/         # Tickets rejeitados (com feedback)
└── template.md       # Template de ticket
```

**Template de Ticket:**
```markdown
# QA Ticket: [FEATURE_ID]

## Feature
- ID: render-003
- Name: LOD 1: Instanced Mesh for Bars

## Visual Criteria
- [ ] Canvas não é uniforme (mais de 5 cores distintas)
- [ ] Pelo menos 100 blocos visíveis
- [ ] Cores esperadas presentes: verde, laranja, cyan

## Developer Notes
[O que foi implementado]

## QA Result
- Status: PENDING | APPROVED | REJECTED
- Screenshot: [path]
- Notes: [feedback do QA]
```

### Fase 2: Criar QA Agent Protocol

**Arquivo:** `CLAUDE.md` - adicionar seção QA Protocol

```markdown
## QA Agent Protocol

Quando ativado como QA Agent:
1. Ler tickets em `qa-tickets/pending/`
2. Para cada ticket:
   a. Ler os critérios visuais
   b. Usar Playwright MCP para:
      - Iniciar app (pnpm dev)
      - Tirar screenshot
      - Analisar visualmente
      - Interagir se necessário (scroll, zoom)
   c. Comparar resultado vs critérios
   d. Mover ticket para approved/ ou rejected/
   e. Adicionar screenshot e feedback
```

### Fase 3: Integrar no Harness

**Arquivo:** `features.json` - adicionar visualCriteria

**Arquivo:** `init.sh` - adicionar check de tickets rejeitados

```bash
# Check for rejected QA tickets
if [ -n "$(ls -A qa-tickets/rejected/ 2>/dev/null)" ]; then
  echo "❌ QA TICKETS REJECTED - Fix before proceeding"
  exit 1
fi
```

### Fase 4: Workflow Developer → QA

1. Developer completa feature
2. Developer cria ticket: `qa-tickets/pending/render-003.md`
3. Developer roda `./init.sh` → falha se há pending tickets sem QA
4. QA Agent é invocado (manual ou automático)
5. QA usa Playwright MCP para verificar
6. QA move ticket para approved/ ou rejected/
7. Se rejected: Developer lê feedback e corrige
8. Loop até approved

---

## Arquivos a Modificar

1. `CLAUDE.md` - Adicionar QA Agent Protocol e data/OS awareness
2. `features.json` - Adicionar `visualCriteria` para features visuais
3. `init.sh` - Adicionar check de QA tickets
4. Criar `qa-tickets/` structure
5. Criar `qa-tickets/template.md`

---

## Questões Pendentes

1. O QA Agent deve rodar automaticamente ou ser invocado manualmente?
2. Os tickets devem ser arquivos markdown ou JSON?
3. Como garantir que Playwright MCP está funcionando corretamente?

---

## Fases de Execução

### FASE 0: Fix Imediato (ANTES de tudo)

**Objetivo:** Corrigir o bug de renderização para que a tela mostre o chart.

**Problema técnico:** `loader.ts` muta TypedArrays diretamente mas não notifica Zustand subscribers.

**Fix em `src/services/mock/loader.ts`:**
```typescript
export function loadScenarioIntoStore(scenario: GeneratedScenario): void {
  const store = getSimulationState();

  // ... populate arrays ...

  // ADICIONAR: Notificar store que dados mudaram
  // Isso trigga os subscribers (incluindo FractalRenderer)
  simulationStore.setState({ schedule: store.schedule });
}
```

**Verificação:**
1. Rodar `pnpm dev`
2. Abrir browser
3. DEVE mostrar barras coloridas, não tela azul

**Commit:** `fix(loader): notify store after populating TypedArrays`

---

### FASE 1: Commit Estado Atual + Atualizar Harness Básico

**Ações:**
1. Commit das correções do Gemini (viewportStore, App.tsx, etc.)
2. Atualizar `init.sh` para mostrar data/OS atual
3. Atualizar snapshot visual com tela CORRETA (após Fase 0)

---

### FASE 2: Sistema de Agentes com Tickets

**Estrutura de Arquivos:**
```
qa-tickets/
├── pending/           # Aguardando QA
├── approved/          # Aprovados
├── rejected/          # Rejeitados com feedback
└── README.md          # Instruções do sistema

insights/
├── session-log.md     # Log de insights entre sessões (resolve Context Loss)
└── known-issues.md    # Problemas conhecidos para não repetir
```

**Workflow:**
```
Developer termina feature
       ↓
Cria ticket em qa-tickets/pending/
       ↓
QA Agent é invocado (automático ou manual)
       ↓
QA Agent usa Playwright MCP para:
  - Iniciar app
  - Tirar screenshot
  - Analisar visualmente
  - Comparar com critérios em features.json
       ↓
Move ticket para approved/ ou rejected/
       ↓
Se rejected: Developer lê feedback e corrige
```

**Critérios Visuais em features.json:**
```json
{
  "id": "render-003",
  "visualCriteria": {
    "check": "LOD 1 bars visible",
    "minColors": 3,
    "canvasNotUniform": true
  }
}
```

---

### FASE 3: (Futura) UX/Cognitive Load

- Avaliar densidade de informação
- Aplicar princípios Gestalt
- Considerar acessibilidade

---

## Arquivos a Modificar

| Fase | Arquivo | Mudança |
|------|---------|---------|
| 0 | `src/services/mock/loader.ts` | Adicionar `setState` após popular arrays |
| 1 | `init.sh` | Mostrar data/OS atual |
| 1 | `e2e/snapshots/` | Atualizar com visual correto |
| 2 | `CLAUDE.md` | Adicionar QA Agent Protocol |
| 2 | `features.json` | Adicionar `visualCriteria` |
| 2 | `qa-tickets/` | Criar estrutura |
| 2 | `insights/` | Criar estrutura para memória entre sessões |

---

## Ordem de Execução

1. **FASE 0** - Fix loader.ts (5 min)
2. **Verificar visualmente** - Tela deve mostrar chart
3. **FASE 1** - Commit tudo (10 min)
4. **FASE 2** - Sistema de tickets (30 min)
5. **Testar sistema completo**

---

## Confirmação Necessária

Antes de executar, confirme:
1. A ordem das fases está correta?
2. O sistema de tickets via arquivos `.md` está OK?
3. Posso prosseguir com Fase 0 imediatamente após aprovação?
