# Plano de Revisao Completa do Projeto MMS

## Objetivo
Realizar uma revisao minuciosa do projeto MMS (Metro Mileage Management System) para identificar falhas logicas, minuciosas e holisticas antes da fase de implementacao.

## Contexto de Urgencia
**FOCO:** Criar demo funcional urgentemente. Priorizar correcoes que bloqueiam desenvolvimento.

## Decisoes do Usuario
- [x] Ignorar problema `@zazcart/toolkit` path local (manter como esta)
- [ ] Criar CLAUDE.md com regras de desenvolvimento
- [ ] Toda documentacao e codigo em **ingles exclusivamente**
- [ ] Commits no git a **cada pequeno step**

---

## 1. Categorias de Revisao

### 1.1 Consistencia Documental
- [ ] Terminologia consistente entre documentos (Playbook, README, Agents)
- [ ] Numeros e intervalos alinhados (PM1, PM2, HM, Overhaul)
- [ ] Referencias cruzadas validas entre secoes
- [ ] Versoes e datas consistentes

### 1.2 Falhas Logicas
- [ ] Contradicoes nas restricoes do solver
- [ ] Fluxos de usuario impossiveis
- [ ] Dependencias circulares
- [ ] Gaps na logica de negocio

### 1.3 Falhas Tecnicas/Arquiteturais
- [ ] Gaps no modelo de dados
- [ ] Problemas na arquitetura do solver
- [ ] Inconsistencias no stack tecnologico
- [ ] Seguranca e performance

### 1.4 Falhas de Dominio Ferroviario
- [ ] Termos incorretos ou imprecisos
- [ ] Intervalos de manutencao irreais
- [ ] Restricoes operacionais faltantes
- [ ] Conformidade com padroes (EN 15380, ECM)

### 1.5 Falhas de UX/UI
- [ ] Jornadas de usuario inconsistentes
- [ ] Personas contradictorias
- [ ] Funcionalidades faltantes vs prometidas
- [ ] Wireframes vs requisitos

### 1.6 Falhas Holisticas
- [ ] Alinhamento entre documentos e agentes
- [ ] Cobertura do escopo IN vs OUT
- [ ] Riscos nao mapeados
- [ ] Dependencias externas nao consideradas

---

## 2. Falhas Identificadas

### 2.1 Inconsistencias nos Intervalos de Manutencao

**Problema Critico:** Os intervalos de PM divergem entre documentos.

| Fonte | PM1 | PM2 | HM/Overhaul |
|-------|-----|-----|-------------|
| Playbook Sec 2.3 | 10,000-30,000 km | 60,000-120,000 km | 6-12 anos |
| Playbook Sec 9.2 (Train Types) | 10,000-15,000 km | 60,000-90,000 km | N/A |
| Agent railway-domain-expert | 30,000-50,000 km | 100,000-150,000 km | 300,000-600,000 km |
| Agent data-engineer | 30,000-80,000 km/ano | N/A | N/A |

**Impacto:** Seed data pode nao corresponder as regras de negocio. Solver pode ter parametros incorretos.

**Recomendacao:** Padronizar intervalos em um unico local de referencia.

---

### 2.2 Modelo de Dados - Gaps Identificados

**Problema 1: Wheelset nao modelado**
- Secao 2.4.1 do Playbook menciona flange < 28.5mm como restricao mandatoria
- Intervalo tipico de ~60,000 km para reprofiling
- Tabela `trains` nao tem campo para `wheelset_km` ou `last_reprofiling_date`
- Desgaste nao-linear nao esta modelado

**Problema 2: Consist/Married Pairs nao modelados**
- Secao 2.4.3 menciona que trens sao composicoes (A+B)
- Married pairs sao inseparaveis
- Schema nao tem relacionamento train_consists ou married_pair_id

**Problema 3: Infrastructure Windows ausente**
- Secao 2.4.8 menciona bloqueio de rotas para manutencao de via
- Nao ha tabela para `route_maintenance_windows`
- Solver pode alocar trem para rota bloqueada

**Problema 4: Crew simplificado demais**
- Secao 2.4.5 menciona restricoes complexas de tripulacao
- Model apenas trata como "simplified constraint"
- Pode invalidar planos "perfeitos" na operacao real

---

### 2.3 Solver - Problemas no Modelo de Otimizacao

**Problema 1: Objetivo quadratico nao suportado em CP-SAT puro**
```
gamma * SUM (km_above_average)^2
```
- CP-SAT suporta objetivos lineares nativamente
- Objetivos quadraticos requerem linearizacao (piecewise)
- Nao ha mencao a como linearizar no Playbook

**Problema 2: Dead running mal definido**
- Constraint 5: "destination depot = next origin depot (or account for dead running)"
- Nao esta claro como calcular distancia de dead running
- Falta tabela de distancias depot-to-depot

**Problema 3: Warm-starting nao especificado**
- Para atender < 30s com 100+ trens
- Warm-starting pode ser critico
- Nenhuma estrategia definida

**Problema 4: Infeasibility handling**
- O que fazer quando solver retorna INFEASIBLE?
- Quais restricoes relaxar?
- Como comunicar ao usuario?

---

### 2.4 Agentes BMAD - Inconsistencias

**Problema 1: Referencias de secao invalidas**
- `railway-domain-expert.md` referencia "Section 2.4" mas deveria ser "Section 2"
- `or-specialist.md` referencia "Section 2.6" mas a hierarquia correta e "Section 2.6"
- Potencial confusao quando agentes tentam carregar contexto

**Problema 2: Parametros de validacao divergentes**
- `railway-domain-expert` diz PM1 = 30-50k km
- Playbook diz PM1 = 10-30k km
- Seed data gerada pelo agente pode conflitar com regras

**Problema 3: Comandos de menu duplicados**
- Ambos `railway-domain-expert` e `data-engineer` tem "VS - Validate Seed"
- Podem ter logicas diferentes de validacao

---

### 2.5 UX/UI - Gaps Identificados

**Problema 1: Gantt nao tem requisitos de interacao claros**
- "Should Have" mas critico para Persona Paul (Maintenance Planner)
- Drag-drop mencionado mas nao especificado tecnicamente
- Conflitos de capacidade: como visualizar?

**Problema 2: Jornada 2 assume funcionalidade nao garantida**
- "Adjusts future allocations to prioritize under-running"
- Isto e feito manualmente ou via solver?
- Como o usuario "aplica changes"?

**Problema 3: WebSocket vs Polling inconsistente**
- Secao 5.1.7 (Alerts): "WebSocket or 30s polling"
- Cache Strategy (8.6): train positions = 30s TTL
- Dashboard: "Numbers updated in < 5s"
- Decisao arquitetural nao definida

---

### 2.6 Seed Data - Problemas de Realismo

**Problema 1: Cenario inicial contraditorio**
- Secao 9.4 diz "km variance = 22%"
- Mas o sistema deve ter alertas quando > 20%
- Seed data comeca ja em estado de "alerta vermelho"?

**Problema 2: Depots portugueses mas sistema internacional**
- Seed usa depots de Portugal (Lisboa, Porto, Faro)
- Sistema menciona "UIC number" europeu, "borders", "homologations"
- Demo pode parecer limitado geograficamente

**Problema 3: 6 meses de historico insuficiente**
- Para mostrar trends de PM2 (60-120k km) ou HM (6-12 anos)
- Historico de 6 meses pode nao capturar ciclos longos
- Graficos de trend podem parecer vazios

---

### 2.7 Riscos Nao Mapeados

**R9: Dependencia do OR-Tools**
- Se OR-Tools tiver breaking changes
- Fallback para Gurobi/CPLEX requer licenca

**R10: TimescaleDB opcional mas critico**
- Mileage history e time-series
- Se nao usar TimescaleDB, queries de trend serao lentas

**R11: Mapbox vs Leaflet decisao pendente**
- Mapbox = mais bonito, requer API key (custo)
- Leaflet = gratuito, menos visual
- Decisao impacta timeline

**R12: gRPC complexidade adicional**
- Fallback REST com 45s timeout
- gRPC adiciona camada de complexidade
- Para demo, REST puro pode ser suficiente

---

### 2.8 Falhas de Escopo

**Problema 1: Multi-language "Could Have" vs Demo Script**
- Script e todo em Ingles
- Demo para cliente pode precisar de PT ou outra lingua
- Contradicao se cliente for europeu continental

**Problema 2: Authentication "Minimal"**
- Nao especifica se OAuth, JWT, ou basic auth
- "Basic authentication sufficient" mas como?
- Usuario/senha hardcoded? Login form?

**Problema 3: Reset capability mencionado mas nao especificado**
- "Ability to reset to demo initial state"
- Como? Script? Botao na UI? API?
- Critico para multiplas apresentacoes

---

## 3. Analise Holistica

### 3.1 Alinhamento Documentos ↔ Agentes

| Aspecto | Playbook | Agents | Status |
|---------|----------|--------|--------|
| PM1 interval | 10-30k km | 30-50k km | **CONFLITO** |
| Solver objective | quadratico | CP-SAT | **GAP** |
| Wheelset modeling | Mencionado | Nao validado | **GAP** |
| Consist modeling | Mencionado | Ausente | **GAP** |
| Demo script | 15 min detalhado | Carlos agent | OK |
| Data model | SQL completo | Diego valida | OK |

### 3.2 Cobertura Funcional

| Requisito Must-Have | Especificado | Modelado | Agente Responsavel |
|---------------------|--------------|----------|-------------------|
| Dashboard KPIs | Sim | Parcial | Vera |
| Map positions | Sim | Sim | Felix |
| Km Balancing | Sim | Sim | Otto |
| Allocation Engine | Sim | Sim | Otto |
| Simulation | Sim | Parcial | Otto |
| Justification | Sim | Sim | Otto |

### 3.3 Dependencias Criticas Nao Documentadas

1. **Node.js >= 20** - nao explicitado no Playbook, apenas inferido
2. **Python 3.11** - mencionado mas sem requirements.txt ou pyproject.toml
3. **Redis** - mencionado para cache mas sem config
4. **PostgreSQL 16** - mencionado mas sem docker-compose ou setup script

---

## 4. Recomendacoes de Correcao

### Alta Prioridade (Corrigir Antes de Implementar)

1. **Padronizar intervalos de manutencao**
   - Criar secao de "Golden Source" no Playbook
   - Atualizar agentes para referenciar essa secao

2. **Modelar wheelsets e consists**
   - Adicionar tabelas ao schema SQL
   - Ou documentar explicitamente como "Out of Scope Phase 1"

3. **Resolver objetivo quadratico**
   - Linearizar com piecewise approximation
   - Ou mudar para objetivo linear ponderado

4. **Definir estrategia de infeasibility**
   - Relaxar restricoes soft primeiro
   - Retornar explicacao ao usuario

### Media Prioridade (Corrigir Durante Sprint 1)

5. **Tabela de distancias depot-to-depot**
6. **Definir WebSocket vs Polling**
7. **Script de reset do demo**
8. **docker-compose para ambiente dev**

### Baixa Prioridade (Corrigir Durante Sprint 2+)

9. **Mapbox vs Leaflet decision**
10. **gRPC vs REST decision**
11. **Authentication strategy**
12. **Multi-language preparation**

---

## 5. Arquivos Criticos para Revisao

| Arquivo | Problema Principal |
|---------|-------------------|
| `/docs/MMS_DEMO_PLAYBOOK.md` | Intervalos PM inconsistentes |
| `/_bmad/custom/agents/railway-domain-expert.md` | Intervalos divergentes |
| `/_bmad/custom/agents/data-engineer.md` | Seed requirements vs playbook |
| `/_bmad/custom/agents/or-specialist.md` | Objetivo quadratico nao tratado |
| `/docs/README.md` | Schema simplificado vs Playbook |

---

## 6. Proximos Passos

1. Revisar e aprovar este plano com o usuario
2. Priorizar correcoes por impacto
3. Atualizar documentos conforme correcoes
4. Validar com agentes de dominio (Maria, Otto)
5. Preparar ambiente de desenvolvimento

---

## 7. Falhas Adicionais Identificadas na Segunda Analise

### 7.1 Demo Timing - Estruturas Divergentes

**Playbook Sec 12.1 (Script Oficial):**
| Min | Secao |
|-----|-------|
| 0-1 | Opening |
| 1-3 | Context |
| 3-5 | Dashboard |
| 5-7 | Map |
| 7-9 | Balancing |
| 9-11 | Allocation |
| 11-13 | Simulation |
| 13-14 | Transparency |
| 14-15 | Closing |

**Agent Carlos (demo-coordinator.md):**
| Duracao | Segmento |
|---------|----------|
| 1 min | Hook (Map) |
| 2 min | Problem |
| 2 min | Solution Overview |
| 6 min | Deep Dive |
| 2 min | Differentiation |
| 2 min | Close |

**CONFLITO:** Estruturas completamente diferentes! Agente Carlos nao segue o script do Playbook.

---

### 7.2 Performance Requirements - Inconsistencias

| Metrica | Playbook | Agent Vera | Agent Felix |
|---------|----------|------------|-------------|
| Map update | < 5 seconds | "sub-second" | N/A |
| Animation FPS | N/A | N/A | 60 FPS minimo |
| Memory limit | N/A | N/A | < 200MB |
| Chart update | N/A | N/A | < 50ms |
| DOM nodes | N/A | N/A | < 5000 |

**Problema:** Felix define thresholds que nao existem no Playbook. Podem conflitar com decisoes de design.

---

### 7.3 Decisoes de Bibliotecas - Nao Resolvidas

| Componente | Playbook | Agent Recomendacao | Status |
|------------|----------|-------------------|--------|
| Charts | Recharts or Chart.js | ECharts (Felix) | **CONFLITO** |
| Maps | Mapbox or Leaflet | react-map-gl (Felix) | **CONFLITO** |
| Gantt | react-gantt-timeline or custom | Custom Canvas (Felix) | **CONFLITO** |
| State | Zustand or React Query | Ambos? (Playbook) | **AMBIGUO** |

**Problema:** Playbook lista opcoes mas nao decide. Agentes recomendam outras. Sem decisao final.

---

### 7.4 Dados de Demo vs Capacidades Tecnicas

| Capacidade | Felix Threshold | Demo Data | Gap? |
|------------|-----------------|-----------|------|
| 10000+ elements | WebGL necessario | 100 trens | **OVERENGINEERING** |
| Virtual scrolling | > 100 items | ~15 depots | **DESNECESSARIO** |
| Canvas rendering | > 1000 points | ~250 services | **TALVEZ** |

**Problema:** Felix assume escala de producao. Demo tem apenas 100 trens. Risco de overengineering.

---

### 7.5 Gantt - Gap de Especificacao

**Mencionado no Playbook:**
- Drag-drop para reagendar manutencao
- Cores por tipo (PM1, PM2, HM)
- Highlight de conflitos de capacidade

**NAO especificado:**
- Como mostrar dependencias entre manutencoes?
- Scroll horizontal infinito ou paginado?
- Zoom levels (dia/semana/mes)?
- Como lidar com manutencoes de 2+ semanas (HM)?
- Indicacao visual de depot capacity por linha temporal?

---

### 7.6 Alertas - Gap de Implementacao

**Playbook Sec 5.1.7:**
- Real-time feed
- Categories: over-running, under-running, maintenance, capacity
- Quick action: 1 click

**NAO especificado:**
- Prioridade/severidade levels?
- Sound/notification permission?
- Persistencia (limpar apos action)?
- Batch actions?
- Snooze/dismiss behavior?

---

### 7.7 Autenticacao - Gap Critico

**Playbook Sec 6.4:** "Basic authentication sufficient"

**NAO especificado:**
- Login form? Bearer token? Session cookie?
- Multi-user isolation de dados?
- Reset password flow (necessario para demo)?
- Role-based access (Admin/Maintenance/Operations)?

**Personas no Playbook (Sec 7.1):**
- Paul (Maintenance Planner)
- Diana (Dispatcher)
- Gabriel (Fleet Manager)

**Problema:** 3 personas com diferentes permissoes, mas auth "minimal". Conflito.

---

### 7.8 Simulacao/What-If - Underspecified

**Playbook Sec 5.1.5:**
- Create scenario (duplicate current state)
- Modify parameters
- Compare results (side-by-side KPIs)
- Projection 30/60/90 days

**NAO especificado:**
- Limite de scenarios ativos?
- Merge scenario back to baseline?
- Colaboracao (scenario compartilhado)?
- Como "modificar parametros"? UI especifica?
- Performance de projecao 90 dias (query complexity)?

---

## 8. Matriz de Risco Atualizada

| ID | Risco | Prob | Impacto | Novo? |
|----|-------|------|---------|-------|
| R1 | Parecer generico | Alta | Fatal | Original |
| R2 | Solver lento | Media | Alto | Original |
| R13 | Overengineering (WebGL desnecessario) | Media | Medio | **NOVO** |
| R14 | Biblioteca choices conflicting | Alta | Medio | **NOVO** |
| R15 | Gantt underspecified | Media | Alto | **NOVO** |
| R16 | Auth/roles nao definido | Media | Medio | **NOVO** |
| R17 | Demo script inconsistente entre docs | Alta | Medio | **NOVO** |

---

## 9. Checklist de Correcoes por Prioridade

### Prioridade CRITICA (Bloqueia Implementacao)

- [ ] **FIX-01:** Padronizar intervalos PM em unico local
- [ ] **FIX-02:** Adicionar wheelsets/consists ao schema OU declarar Out of Scope
- [ ] **FIX-03:** Resolver objetivo quadratico (linearizar)
- [ ] **FIX-04:** Definir estrategia de infeasibility
- [ ] **FIX-05:** Decidir bibliotecas (charts, maps, gantt, state)

### Prioridade ALTA (Corrigir em Sprint 1)

- [ ] **FIX-06:** Alinhar demo script entre Playbook e Agent Carlos
- [ ] **FIX-07:** Especificar Gantt interactions completamente
- [ ] **FIX-08:** Definir auth strategy e roles
- [ ] **FIX-09:** Tabela de distancias depot-to-depot
- [ ] **FIX-10:** WebSocket vs Polling decisao final

### Prioridade MEDIA (Corrigir em Sprint 2)

- [ ] **FIX-11:** Especificar alertas (severidade, persistence, batch)
- [ ] **FIX-12:** Especificar what-if/simulation UI
- [ ] **FIX-13:** Reset demo capability implementation
- [ ] **FIX-14:** Performance thresholds unificados entre docs
- [ ] **FIX-15:** docker-compose para dev environment

---

## 10. Recomendacao Final

**Estado do Projeto:** O projeto tem excelente documentacao de dominio e arquitetura de alto nivel, mas apresenta:

1. **~17 inconsistencias identificadas** entre documentos
2. **~12 gaps de especificacao** que bloqueiam implementacao
3. **~5 decisoes pendentes** sobre bibliotecas/tecnologias
4. **~4 riscos nao mapeados** anteriormente

**Recomendacao:** Antes de iniciar Sprint 1, executar uma "Sprint 0" de 2-3 dias para:
1. Resolver todas as inconsistencias CRITICAS
2. Tomar decisoes de bibliotecas
3. Especificar gaps de implementacao
4. Criar ambiente de desenvolvimento (docker-compose)
5. Validar com Agent Maria (railway-domain-expert) os intervalos finais

---

---

## 11. Problemas Tecnicos de Configuracao

### 11.1 package.json - Issues Criticos

**Arquivo atual:**
```json
{
  "name": "mms",
  "module": "src/index.ts",
  "type": "module",
  "devDependencies": {
    "@types/bun": "latest",
    "@zazcart/toolkit": "file:/usr/local/packages/toolkit"
  },
  "peerDependencies": {
    "typescript": "^5"
  }
}
```

**Problemas identificados:**

| Issue | Problema | Impacto |
|-------|----------|---------|
| Path local | `file:/usr/local/packages/toolkit` nao existira em outros devs/CI | **BLOQUEIO** |
| Deps faltantes | Next.js, React, Tailwind, etc. nao instalados | **BLOQUEIO** |
| Entry point | `src/index.ts` nao existe | Warning |
| Version pinning | `latest` para @types/bun pode quebrar | Medio |

### 11.2 Dependencias Necessarias Nao Instaladas

**Stack planejado (Playbook Sec 8.2) vs package.json:**

| Dependencia | Necessaria | Instalada | Status |
|-------------|------------|-----------|--------|
| next | 14.x | - | **FALTA** |
| react | 18.x | - | **FALTA** |
| react-dom | 18.x | - | **FALTA** |
| tailwindcss | 3.x | - | **FALTA** |
| @radix-ui/* | latest | - | **FALTA** (shadcn/ui) |
| zustand | 4.x | - | **FALTA** |
| @tanstack/react-query | 5.x | - | **FALTA** |
| recharts ou chart.js | latest | - | **FALTA** |
| mapbox-gl ou leaflet | latest | - | **FALTA** |
| typescript | 5.x | peerDep apenas | **FALTA** |

### 11.3 Configuracoes Faltantes

| Config | Status | Necessaria Para |
|--------|--------|-----------------|
| .env.example | Ausente | Variaveis de ambiente |
| docker-compose.yaml | Ausente | PostgreSQL + Redis local |
| requirements.txt / pyproject.toml | Ausente | Python solver dependencies |
| .eslintrc | Ausente | Linting |
| .prettierrc | Ausente | Formatting |
| next.config.js | Ausente | Next.js config |
| tailwind.config.js | Ausente | Tailwind config |
| vitest.config.ts | Ausente | Testing |
| playwright.config.ts | Ausente | E2E testing |

### 11.4 Estrutura src/ Planejada vs Real

**Playbook espera:**
```
src/
├── frontend/    # Next.js
├── backend/     # Node.js/Fastify
└── solver/      # Python OR-Tools
```

**Realidade:**
```
src/
└── (vazio - nao existe)
```

### 11.5 BMAD Output - Nenhum Artefato Gerado

**Diretorio `_bmad-output/` esperado:**
- planning-artifacts/ (PRD, Architecture, UX specs)
- implementation-artifacts/ (code, tests)

**Status:** Vazios. Nenhum workflow BMAD foi executado ainda.

**Implicacao:** Projeto ainda nao passou por:
- Phase 1 (Analysis)
- Phase 2 (Planning) - PRD
- Phase 3 (Solutioning) - Architecture, UX, Epics

---

## 12. Resumo Executivo

### Metricas da Revisao

| Categoria | Total Issues |
|-----------|--------------|
| Inconsistencias documentais | 17 |
| Gaps de especificacao | 12 |
| Decisoes pendentes | 5 |
| Riscos nao mapeados | 4 |
| Problemas tecnicos/config | 11 |
| **TOTAL** | **49** |

### Estado Geral

| Aspecto | Score | Justificativa |
|---------|-------|---------------|
| Documentacao de dominio | A | Playbook excelente, glossario completo |
| Arquitetura alto nivel | B+ | Bem definida mas com gaps de detalhe |
| Modelo de dados | B | Completo mas falta wheelset/consist |
| Agentes BMAD | B- | Bem estruturados mas com inconsistencias |
| Configuracao tecnica | D | Quase nada configurado |
| Ambiente de dev | F | Nao existe |

### Bloqueadores para Implementacao

1. **Path local em package.json** - `file:/usr/local/packages/toolkit`
2. **Dependencias nao instaladas** - Nenhuma dep de producao
3. **Intervalos PM inconsistentes** - Qual e o correto?
4. **Objetivo quadratico no CP-SAT** - Precisa linearizar
5. **Decisoes de bibliotecas** - Charts/Maps/Gantt/State

---

## 13. Proximos Passos Recomendados (FOCO: DEMO URGENTE)

### IMEDIATO - Acao 1: Criar CLAUDE.md

**Arquivo:** `/CLAUDE.md` (raiz do projeto)

**Conteudo obrigatorio:**
```markdown
# MMS Development Guidelines

## Language Policy
- ALL code, comments, and documentation MUST be in English only
- No Portuguese or other languages in any files
- Git commit messages in English

## Git Workflow
- Commit after EVERY small step completed
- Use conventional commits: feat:, fix:, docs:, refactor:, test:
- Never batch multiple features in one commit
- Commit message format: `type: brief description`

## Tech Stack (ZUI Architecture)
- **Frontend:** Next.js 14 + React 18 + TypeScript
- **ZUI Engine:** PixiJS (@pixi/react) for WebGL canvas rendering
- **Charts:** Apache ECharts (WebGL rendering)
- **Gantt:** Bryntum or SVAR (virtual scrolling)
- **State:** @zazcart/toolkit state-machine + TanStack Query
- **Backend:** Elysia.js (Bun runtime)
- **Database:** PostgreSQL 16 with JSONB
- **Optimization:** glpk.js (server) / YALPS (client)

## Development Standards
- TypeScript strict mode
- ESLint + Prettier for formatting
- Canvas/WebGL for > 1000 elements
- SVG only for < 1000 interactive elements
- Virtual scrolling for lists > 100 items
- 60 FPS minimum for animations

## Project References
- Primary spec: /docs/MMS_DEMO_PLAYBOOK.md
- Domain glossary: Section 2.1
- Demo script: Section 12
```

### IMEDIATO - Acao 2: Padronizar Intervalos PM

**Decisao necessaria:** Usar valores do Playbook Sec 2.3 como fonte de verdade:
- PM1: 10,000-30,000 km
- PM2: 60,000-120,000 km
- HM: 6-12 years
- Overhaul: 12-20 years

**Atualizar:** Agent `railway-domain-expert.md` para alinhar

### IMEDIATO - Acao 3: Stack ZUI Definitivo

**NOVA ARQUITETURA:** Semantic Zoomable User Interface

| Layer | Technology | Justification |
|-------|-----------|---------------|
| **ZUI Engine** | PixiJS (@pixi/react) | WebGL performance, React integration |
| **Zoom/Pan** | (agents decide) | Let agents choose best approach |
| **Gantt** | Bryntum (enterprise) / SVAR (OSS) | Virtual scrolling, dependencies |
| **Charts** | Apache ECharts | 1M+ points, WebGL, heatmaps |
| **Calendar** | FullCalendar Premium | Resource timeline, virtual scroll |
| **State** | @zazcart/toolkit state-machine | Lightweight, type-safe, normalized |
| **Server Cache** | TanStack Query | Optimistic updates, caching |
| **Virtualization** | TanStack Virtual | Headless, 2D grid support |
| **Backend** | Elysia.js (Bun) | TypeBox schemas, WebSocket, TypeScript DX |
| **Workers** | Bun Worker + Comlink | Native TS, smol mode, pool pattern |
| **Optimization** | glpk.js (server) / YALPS (client) | LP/MIP solving, lightweight client |
| **Database** | PostgreSQL 16 | Reliable, JSONB for flexibility |
| **Persistence** | IndexedDB (idb-keyval) | Large scenario caching |

**Semantic Zoom Levels:**
```typescript
const useSemanticZoomLevel = (scale: number): ZoomLevel => {
  if (scale < 0.1) return 'decade';      // 10-year strategic
  if (scale < 0.25) return 'annual';
  if (scale < 0.5) return 'quarterly';
  if (scale < 1) return 'monthly';
  if (scale < 2) return 'weekly';
  return 'daily';                        // Tactical planning
};
```

**IMPACTO - Mudancas no Playbook:**
- Fastify → Elysia.js
- OR-Tools Python → glpk.js/YALPS (JavaScript)
- Recharts → Apache ECharts
- Zustand → @zazcart/toolkit state-machine
- Adicionar PixiJS para canvas rendering

### Sprint 0 (1-2 dias apenas)

1. [ ] Criar CLAUDE.md
2. [ ] Setup Next.js 14 app com App Router
3. [ ] Instalar shadcn/ui + Tailwind
4. [ ] Instalar stack ZUI:
   - PixiJS + @pixi/react
   - Apache ECharts
   - @zazcart/toolkit (state-machine)
   - TanStack Query + TanStack Virtual
5. [ ] Setup Elysia.js backend (Bun)
6. [ ] docker-compose para PostgreSQL
7. [ ] Estrutura de pastas monorepo

### Sprint 1 - Foco Demo (ZUI Foundation)

1. ZUI Container base com semantic zoom
2. Dashboard com KPIs mockados (ECharts)
3. Canvas base layer para trens (PixiJS)
4. State normalization setup (@zazcart/toolkit)

**Sprint 2 - Visualizacoes:**
1. Gantt chart com virtual scrolling
2. Heatmap de manutencao (ECharts)
3. Mapa interativo com clustering

**NAO fazer ate Sprint 3:**
- Solver real (YALPS/glpk.js)
- Simulacao what-if completa
- Auth real

---

## 14. Diagrama de Arquitetura ZUI Atualizado

```
┌─────────────────────────────────────────────────────────────────┐
│                      ZUI Container Layer                         │
│                   (agents decide zoom/pan lib)                   │
├─────────────────────────────────────────────────────────────────┤
│            Semantic Zoom Manager (useSemanticZoomLevel)          │
├────────────────┬────────────────┬───────────────────────────────┤
│  Gantt View    │  Calendar View │    Analytics View              │
│  (Bryntum +    │  (FullCalendar)│    (Apache ECharts)           │
│   PixiJS)      │                │                                │
├────────────────┴────────────────┴───────────────────────────────┤
│    State Layer (@zazcart/toolkit state-machine + TanStack Query) │
├─────────────────────────────────────────────────────────────────┤
│  Cache: React Query (in-memory) → IndexedDB (persistent)        │
├─────────────────────────────────────────────────────────────────┤
│                   Elysia.js API Server (Bun)                     │
│        WebSocket pub/sub │ Worker Pool (glpk.js)                 │
├─────────────────────────────────────────────────────────────────┤
│                   PostgreSQL 16 (JSONB)                          │
└─────────────────────────────────────────────────────────────────┘
```

---

## 15. Normalized State Structure

```typescript
interface NormalizedPlanningState {
  trains: { byId: Record<string, Train>; allIds: string[] };
  yearPlans: { byId: Record<string, YearPlan>; allIds: string[] };
  maintenanceEvents: { byId: Record<string, Event>; allIds: string[] };
}

interface ScenarioStore {
  scenarios: Record<string, NormalizedPlanningState>;
  activeScenarioId: string;
  comparisonScenarioIds: string[];  // Side-by-side comparison
}
```

---

## 16. Data Aggregation Levels

| Zoom Level | Aggregation | Records per Train |
|------------|-------------|-------------------|
| Decade | Yearly | 10 |
| Annual | Monthly | 120 |
| Quarterly | Weekly | 520 |
| Daily | Individual | 3,650 |

**Total para 300 trens:**
- Decade view: 3,000 records
- Daily view: 1,095,000 records

**Estrategia:** Pre-compute aggregations server-side, fetch by viewport + buffer

---

## 17. Arquivos que Precisam ser Atualizados

### 17.1 Arquivos a CRIAR

| Arquivo | Proposito |
|---------|-----------|
| `/CLAUDE.md` | Regras de desenvolvimento |
| `/docker-compose.yaml` | PostgreSQL container |
| `/packages/frontend/` | Next.js app |
| `/packages/backend/` | Elysia.js API |
| `/packages/shared/` | Types compartilhados |
| `/.env.example` | Variaveis de ambiente |

### 17.2 Documentos a ATUALIZAR (Stack Mismatch)

| Arquivo | Mudanca Necessaria |
|---------|-------------------|
| `/docs/MMS_DEMO_PLAYBOOK.md` | Sec 8.1-8.7: Fastify → Elysia, OR-Tools → glpk.js, Recharts → ECharts, add PixiJS |
| `/docs/README.md` | Atualizar stack overview |

**Secoes especificas do Playbook a revisar:**
- Sec 8.1 Overview: Diagrama de arquitetura
- Sec 8.2 Technology Stack: Tabela completa
- Sec 8.3 Data Model: Keep PostgreSQL, review schema
- Sec 8.4 Solver: Python OR-Tools → glpk.js/YALPS
- Sec 8.5 Backend API: Fastify → Elysia
- Sec 8.6 Cache Strategy: Redis → TanStack Query + IndexedDB
- Sec 8.7 API-Solver Communication: gRPC → Worker threads

### 17.3 Agentes BMAD a ATUALIZAR

| Agente | Arquivo | Mudanca |
|--------|---------|---------|
| data-engineer (Diego) | `/_bmad/custom/agents/data-engineer.md` | Keep PostgreSQL, update refs for Elysia/glpk.js |
| or-specialist (Otto) | `/_bmad/custom/agents/or-specialist.md` | OR-Tools → glpk.js/YALPS |
| frontend-viz-dev (Felix) | `/_bmad/custom/agents/frontend-viz-dev.md` | Adicionar PixiJS, ECharts refs |
| dataviz-designer (Vera) | `/_bmad/custom/agents/dataviz-designer.md` | Recharts → ECharts refs |

**Mudancas especificas por agente:**

**Diego (data-engineer.md):**
- Sec expertise: Keep PostgreSQL, add refs to Elysia.js backend
- Sec seed_data_requirements: Keep SQL schema, align with Playbook intervals
- Update context refs to match new tech stack

**Otto (or-specialist.md):**
- Linha 53: OR-Tools → glpk.js/YALPS
- Sec expertise: Python → JavaScript/TypeScript
- Sec two_stage_architecture: Atualizar refs

**Felix (frontend-viz-dev.md):**
- Sec tech_stack: Confirmar PixiJS + ECharts
- Sec library_recommendations: Alinhar com stack escolhido
- Sec performance_thresholds: Manter (ja adequado)

**Vera (dataviz-designer.md):**
- Sec chart_recommendations: Recharts → ECharts equivalents
- Adicionar refs a PixiJS para canvas layer

### 17.4 Configuracoes a ATUALIZAR

| Arquivo | Mudanca |
|---------|---------|
| `/package.json` | Adicionar deps (Elysia, PixiJS, ECharts, etc.) |
| `/tsconfig.json` | Verificar paths para monorepo |
| `/_bmad/bmm/config.yaml` | Verificar project refs |
| `/_bmad/custom/module.yaml` | Verificar agent refs |

### 17.5 Arquivos SEM mudanca necessaria

| Arquivo | Razao |
|---------|-------|
| `railway-domain-expert.md` | Dominio ferroviario, nao depende de stack |
| `demo-coordinator.md` | Estrategia de demo, stack-agnostic |
| Core BMAD workflows | Framework, nao projeto especifico |

---

## 18. Ordem de Execucao das Atualizacoes

### Fase 1: Fundacao (1-2 horas)
1. Criar CLAUDE.md
2. Commit: `docs: add CLAUDE.md with development guidelines`

### Fase 2: Atualizar Documentacao Principal (2-3 horas)
3. Atualizar MMS_DEMO_PLAYBOOK.md Sec 8 (Architecture)
4. Commit: `docs: update tech stack to ZUI architecture`
5. Atualizar README.md com nova stack
6. Commit: `docs: update README with new tech stack`

### Fase 3: Alinhar Agentes BMAD (1-2 horas)
7. Atualizar data-engineer.md (Diego) - align with new stack
8. Commit: `docs: update data-engineer agent stack refs`
9. Atualizar or-specialist.md (Otto) - glpk.js
10. Commit: `docs: update or-specialist agent for glpk.js`
11. Atualizar frontend-viz-dev.md (Felix) - confirmar stack
12. Commit: `docs: update frontend-viz-dev agent stack refs`
13. Atualizar dataviz-designer.md (Vera) - ECharts
14. Commit: `docs: update dataviz-designer agent for ECharts`

### Fase 4: Setup Projeto (2-4 horas)
15. Criar estrutura monorepo (packages/)
16. Commit: `feat: initialize monorepo structure`
17. Setup Next.js frontend
18. Commit: `feat: setup Next.js 14 frontend`
19. Setup Elysia backend
20. Commit: `feat: setup Elysia.js backend`
21. Criar docker-compose.yaml
22. Commit: `infra: add docker-compose for PostgreSQL`

---

*Plano gerado em: 2025-12-28*
*Revisao solicitada: Completa (logica, minuciosa, holistica)*
*Total de issues identificados: 49*
*Arquivos analisados: 15+*
*Agentes analisados: 6*
