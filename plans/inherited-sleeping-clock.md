# Plano: Redesign das Visualizações com Avaliação Visual

## Objetivo
Redesenhar as visualizações do What-If Simulator para demonstrar VALOR ao cliente, não apenas mostrar números. O cliente deve conseguir **validar** cada decisão do sistema.

## Mudança de Abordagem
**Antes**: Escrever código às cegas → esperar que fique bom
**Agora**: Configurar Playwright MCP → ver a UI → iterar com feedback visual

---

## Fase 0: Setup do Playwright MCP (Visual Evaluation)

### Por que isso é crítico
- Permite que eu VEJA a UI renderizada enquanto desenvolvo
- Posso avaliar UX, estética e "impressionabilidade"
- Itero baseado em feedback visual real, não suposições

### Passos
1. Instalar Playwright MCP no projeto:
   ```bash
   claude mcp add playwright -- npx @playwright/mcp@latest
   ```

2. Criar arquivo `.mcp.json` no projeto (para equipe):
   ```json
   {
     "mcpServers": {
       "playwright": {
         "command": "npx",
         "args": ["@playwright/mcp@latest"]
       }
     }
   }
   ```

3. Workflow de desenvolvimento:
   - Terminal 1: `cd apps/web && pnpm dev`
   - Terminal 2: Claude Code com Playwright MCP
   - Comando: "Take a screenshot of localhost:3000/what-if"

---

## Fase 1: Remover Exposição Técnica

### Arquivos a modificar
- `apps/web/src/components/WhatIfSimulator.tsx`
- `apps/web/src/components/AdvancedVisualizations.tsx`

### Remover completamente
1. **Tab "Solver Details"** (linhas 366-381 em WhatIfSimulator.tsx)
   - Remove: `SolverDiagnosticsDisplay` component
   - Remove: Toda a tab que mostra HiGHS, iterations, MIP gap, etc.

2. **Jargão técnico**
   - "HiGHS MIP Solver" → "Optimization Engine"
   - "Running HiGHS MIP Solver..." → "Calculating optimal schedule..."
   - "mip_gap", "node_count", "iterations" → NÃO MOSTRAR

### Arquivos afetados
- `AdvancedVisualizations.tsx`: Deletar `SolverDiagnosticsDisplay` (linhas 663-745)

---

## Fase 2: Mostrar o RACIOCÍNIO

### Problema atual
Cliente vê: "Peak Workload: 1,408" mas não sabe SE está correto

### Solução: Visualização de "Decision Trace"

Para cada evento agendado, mostrar:
1. **Input**: Qual era a regra de manutenção (a cada X km)
2. **Constraint**: Janela permitida (semana 5-9)
3. **Conflict**: O que impediu agendar na data ideal
4. **Decision**: Por que foi agendado na semana 7
5. **Impact**: Efeito no workload total

### Novo componente: `DecisionExplainer`
```tsx
// Quando usuário clica em um evento no Gantt
interface DecisionExplanation {
  eventId: string;
  trainId: string;
  maintenanceType: string;

  // O que pedimos
  targetWeek: number;
  allowedWindow: { earliest: number; latest: number };

  // Por que não foi possível na data ideal
  conflicts: {
    week: number;
    reason: string; // "Capacity exceeded by 200 man-hours"
  }[];

  // Onde colocamos
  assignedWeek: number;

  // Impacto
  workloadBefore: number;
  workloadAfter: number;
}
```

---

## Fase 3: Melhorar Visualizações Existentes

### 3.1 Before/After (WorkloadComparison)
**Atual**: Dois gráficos de barras lado a lado
**Melhorar**:
- Adicionar setas mostrando "fluxo" de eventos movidos
- Destacar redução de pico com animação
- Mostrar economia em números grandes

### 3.2 Schedule Timeline (ScheduleGantt)
**Atual**: Timeline básico com eventos
**Melhorar**:
- Hover mostra explicação do agendamento
- Click abre `DecisionExplainer`
- Cor indica se está no target (verde) ou desviado (amarelo/vermelho)

### 3.3 Constraint Proof
**Atual**: Lista de checks (PASSED/FAILED)
**Melhorar**:
- Para cada constraint, mostrar evidência visual
- "Weekly Capacity: All 13 weeks within 5,200 man-hours"
  - Mostrar mini-gráfico com linha de capacidade

---

## Fase 4: Inspiração do Mercado

### Palantir Foundry (referência OURO)
- Drag-and-drop Gantt
- Simulador de cenários lado a lado
- Visualização de trade-offs

### Bryntum Scheduler Pro
- Resource histograms profissionais
- Conflict detection visual
- Zoom timeline (day/week/month/year)

### Implementar
- Resource histogram estilo Tensix P6
- Timeline zoomável (hierarquia Fraunhofer: Strategic → Tactical → Operational)

---

## Arquivos Críticos a Modificar

| Arquivo | Mudança |
|---------|---------|
| `apps/web/src/components/WhatIfSimulator.tsx` | Remover tab Solver Details, melhorar UX |
| `apps/web/src/components/AdvancedVisualizations.tsx` | Deletar SolverDiagnosticsDisplay, adicionar DecisionExplainer |
| `apps/web/src/components/WorkloadChart.tsx` | Melhorar Before/After comparison |
| `.mcp.json` (novo) | Configurar Playwright MCP |

---

## Workflow de Implementação

```
1. Setup Playwright MCP
   ↓
2. Screenshot da UI atual (baseline)
   ↓
3. Remover Solver Details tab
   ↓
4. Screenshot → Avaliar
   ↓
5. Implementar DecisionExplainer
   ↓
6. Screenshot → Avaliar UX
   ↓
7. Melhorar visualizações existentes
   ↓
8. Screenshot → Comparar com baseline
   ↓
9. Iterar até impressionar
```

---

## Critérios de Sucesso

### Visual
- [ ] Nenhum jargão técnico visível (HiGHS, MIP, iterations)
- [ ] Cliente consegue clicar em qualquer número e ver explicação
- [ ] Design profissional comparável a Palantir/Bryntum

### Funcional
- [ ] Before/After mostra claramente o valor da otimização
- [ ] Cada decisão de agendamento é explicável
- [ ] Constraint proof mostra evidências, não apenas "PASSED"

### Impressionabilidade
- [ ] Screenshot final é algo que queremos mostrar ao cliente
- [ ] UI demonstra competência técnica sem expor detalhes proprietários

---

## Fontes de Inspiração

- [Microsoft Playwright MCP](https://github.com/microsoft/playwright-mcp)
- [Palantir Foundry Dynamic Scheduling](https://www.palantir.com/platforms/foundry/dynamic-scheduling/)
- [Bryntum Scheduler Pro Examples](https://bryntum.com/products/schedulerpro/examples/)
- [Simon Willison - Playwright MCP with Claude Code](https://til.simonwillison.net/claude-code/playwright-mcp-claude-code)
