# Plano de Testes e Correções - MMS-MFC

## Descobertas Críticas da Análise

### DESCOBERTA 1: Epic 6 (Gantt) - Problema é DADOS, não Canvas
O MaintenanceGantt.tsx **NÃO usa Pixi.js** - usa renderização HTML/DOM pura.
O componente está estruturalmente correto. O problema é **AUSÊNCIA DE DADOS**.

**Causa Raiz:** O seed gera datas relativas (`randomInt(-60, 30)` dias).
Se executado há semanas, os dados "futuros" já estão no passado.

### DESCOBERTA 2: Epic 5 (What-If) - Implementação MAIS COMPLETA
A documentação SCP-001 está desatualizada. SimulationPanel.tsx tem **670 linhas**
de código funcional com UI completa (criar cenário, editor de alocação,
comparação multi-cenário, apply to live).

**Problema Real:** Integração/dados, não implementação faltante.
- Cenários usam Map in-memory (perdidos no restart)
- Solver Python pode não estar rodando

### DESCOBERTA 3: Zero Infraestrutura de Testes
- Nenhum arquivo de teste existe
- Vitest não instalado
- Playwright não instalado
- 0% coverage

---

## Plano de Execução (6 Fases)

### FASE 1: Diagnóstico Visual Inicial (30 min)
**Objetivo:** Verificar estado atual real de todas as páginas

```bash
# 1. Iniciar serviços
docker-compose up -d postgres redis
cd apps/api && bun run db:migrate && bun run db:seed && bun run dev &
cd apps/web && bun run dev &

# 2. Verificar API
curl http://localhost:4000/health
curl http://localhost:4000/api/maintenance/gantt | jq '.trains | length'
curl http://localhost:4000/api/services/pending | jq '. | length'
```

**Screenshot de cada página via Playwright MCP:**
- [ ] Dashboard (/)
- [ ] Map (/map)
- [ ] Allocation (/allocation)
- [ ] Fleet (/fleet)
- [ ] Balancing (/balancing)
- [ ] Schedule (/schedule)
- [ ] Maintenance (/maintenance)

---

### FASE 2: Correção de Dados - Epic 6 (1 hora)
**Objetivo:** Resolver problema de dados vazios no Gantt

#### Ação 2.1: Re-executar Seed
```bash
cd apps/api && bun run db:seed
```

#### Ação 2.2: Melhorar Seed (se necessário)
**Arquivo:** `apps/api/src/db/seed.ts` (linha ~293)

```typescript
// DE:
const daysOffset = randomInt(-60, 30);

// PARA:
const daysOffset = i < eventCount / 2
  ? randomInt(1, 28)   // 50% no futuro (próximas 4 semanas)
  : randomInt(-60, 0); // 50% no passado
```

#### Verificação:
```bash
curl http://localhost:4000/api/maintenance/gantt | jq '.trains[0].events | length'
# Deve retornar > 0
```

---

### FASE 3: Correção de Integração - Epic 5 (2 horas)
**Objetivo:** Garantir que What-If Scenarios funcione end-to-end

#### Ação 3.1: Verificar Solver Python
```bash
cd apps/solver
pip install -r requirements.txt
python -m uvicorn src.main:app --port 8000 &
curl http://localhost:8000/health
```

#### Ação 3.2: Corrigir Query de Services
**Arquivo:** `apps/api/src/routes/services.ts`

Problema: "No pending services" se todos já alocados.
Solução: Mostrar todos os services em modo simulação.

#### Ação 3.3: Persistir Cenários em DB (Opcional)
**Arquivo:** `apps/api/src/routes/simulation.ts`

Problema: Cenários em Map in-memory são perdidos no restart.
Solução: Criar tabela `scenarios` ou usar Redis.

---

### FASE 4: Instalação de Test Framework (1 hora)
**Objetivo:** Configurar Playwright + Vitest para testes automatizados

#### Ação 4.1: Instalar Dependências
```bash
cd /Users/anotonio.silva/antonio/mms/MFC

# Playwright + Vitest
bun add -D @playwright/test vitest @vitest/coverage-v8 @vitest/ui
bun add -D @testing-library/react @testing-library/jest-dom jsdom

# Instalar browsers
npx playwright install chromium
```

#### Ação 4.2: Criar Configurações

**Criar:** `vitest.config.ts` (root)
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    projects: [
      'apps/web/vitest.config.ts',
      'apps/api/vitest.config.ts',
    ],
  },
});
```

**Criar:** `apps/web/playwright.config.ts`
```typescript
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  webServer: {
    command: 'bun run dev',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

#### Ação 4.3: Criar Estrutura de Diretórios
```
apps/web/
├── __tests__/components/     # Unit tests (Vitest)
├── e2e/pages/                # E2E tests (Playwright)
└── vitest-setup.ts

apps/api/
└── __tests__/routes/         # API tests (Vitest)
```

---

### FASE 5: Testes E2E de Todas as Páginas (2 horas)
**Objetivo:** Criar testes Playwright para verificar UI

#### Criar: `apps/web/e2e/pages/dashboard.spec.ts`
```typescript
import { test, expect } from '@playwright/test';

test.describe('Dashboard', () => {
  test('renders KPI cards', async ({ page }) => {
    await page.goto('/');
    await expect(page.locator('.bp5-card')).toHaveCount.greaterThan(0);
  });
});
```

#### Testes a Criar (1 por página):
- [ ] `dashboard.spec.ts` - KPIs, depot cards, alerts
- [ ] `map.spec.ts` - Leaflet render, markers, filters
- [ ] `allocation.spec.ts` - Service list, recommendations
- [ ] `fleet.spec.ts` - Verificar se é stub ou implementado
- [ ] `balancing.spec.ts` - Charts, simulation panel
- [ ] `schedule.spec.ts` - Canvas render, LOD controls
- [ ] `maintenance.spec.ts` - Gantt, drag-drop, heatmap

---

### FASE 6: Verificação Final e Documentação (1 hora)
**Objetivo:** Atualizar status das stories e documentar

#### Ação 6.1: Re-verificar Todas as Stories
Usar Playwright MCP para screenshot final de cada funcionalidade.

#### Ação 6.2: Atualizar sprint-status.yaml
Marcar stories como `done` ou manter `broken` com motivo documentado.

#### Ação 6.3: Atualizar features.json
Sincronizar com sprint-status.yaml.

---

## Arquivos Críticos

### Frontend
| Arquivo | Propósito |
|---------|-----------|
| `apps/web/src/components/maintenance/MaintenanceGantt.tsx` | Gantt (funcional, precisa de dados) |
| `apps/web/src/components/balancing/SimulationPanel.tsx` | What-If (completo, verificar integração) |
| `apps/web/src/components/schedule/ScheduleCanvas.tsx` | Canvas Pixi.js (verificar render) |

### Backend
| Arquivo | Propósito |
|---------|-----------|
| `apps/api/src/db/seed.ts` | Seed - ajustar datas para futuro |
| `apps/api/src/routes/maintenance.ts` | API Gantt - verificar queries |
| `apps/api/src/routes/simulation.ts` | API Simulation - verificar fallback |

### Configuração
| Arquivo | Criar/Modificar |
|---------|-----------------|
| `vitest.config.ts` | CRIAR - root config |
| `apps/web/vitest.config.ts` | CRIAR - web config |
| `apps/web/playwright.config.ts` | CRIAR - E2E config |
| `package.json` | MODIFICAR - adicionar scripts |

---

## Ordem de Execução Recomendada

| # | Fase | Tempo | Prioridade |
|---|------|-------|------------|
| 1 | Diagnóstico Visual | 30 min | CRÍTICO |
| 2 | Correção Dados (Epic 6) | 1h | CRÍTICO |
| 3 | Correção Integração (Epic 5) | 2h | ALTA |
| 4 | Install Test Framework | 1h | ALTA |
| 5 | Testes E2E | 2h | MÉDIA |
| 6 | Documentação Final | 1h | MÉDIA |

**Tempo Total Estimado:** ~7.5 horas

---

## Critérios de Sucesso

### Epic 6 - Maintenance Gantt
- [ ] Gantt mostra blocos de manutenção
- [ ] Drag-drop funciona
- [ ] Depot capacity mostra % > 0

### Epic 5 - What-If Scenarios
- [ ] Criar cenário funciona
- [ ] Allocation editor carrega services/trains
- [ ] Run simulation retorna resultados
- [ ] Comparação multi-cenário funciona

### Test Framework
- [ ] `bun run test` executa Vitest
- [ ] `bun run test:e2e` executa Playwright
- [ ] Pelo menos 1 teste por página

---

## Workflows BMAD a Usar

```bash
# Para cada correção de bug
/correct-course

# Para verificar status
/sprint-status

# Para implementar stories novas (se necessário)
/dev-story [story-id]

# Após completar epic
/code-review
```
