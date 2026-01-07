# Plano: Especificação de Implementação - Demo MMS

## Objetivo
Criar um documento de especificação técnica (`docs/DESIGN_SPEC.md`) que servirá como guia INTERNO para implementação da demo interativa com Astro.js + deck.gl. A demo é o que impressionará o cliente e vencerá a licitação.

---

## Princípios

### Fonte Única de Verdade
- **APENAS `docs/RFQ.md`** - ignorar todo código e documentação existente
- Começar do ZERO - visão fresca baseada nos requisitos do cliente
- Pesquisa web para referências visuais e melhores práticas

### Propósito do Documento
- Especificação técnica para desenvolvedores internos
- Guia completo para implementar cada tela/componente
- Referências visuais (moodboard) para alinhar visão do produto
- Dados mockados - sem backend real

### Stack Tecnológico
- **Astro.js** - Framework frontend
- **deck.gl** - Visualização WebGL
- **Mocks** - Dados simulados (128 trens, 12 anos de tarefas)

---

## Contexto do RFQ (Fonte Única)

### Scope of Work (Página 1)
- 128 trens (49 Kinki Sharyo + 79 Alstom)
- Sistema de mileage management automatizado
- 3 categorias: Maintenance Planning, Operational Planning, Resource Planning

### Dores do Cliente (Background - Página 2)
1. Sem ferramentas dedicadas para mileage management
2. IBM Maximo só faz asset management, não mileage
3. Gerenciamento manual via Excel
4. Dados de mileage armazenados manualmente (folder-driven)
5. Falta de integração entre manutenção e operações
6. Risco de non-compliance por mileage underrun/overrun
7. Falta de simulações preditivas
8. Visibilidade insuficiente de recursos vs utilização
9. Handling manual causando atrasos e ineficiências

### Outputs Requeridos (Página 3)
- Centralised dashboard
- Mileage status de todos os trens
- Train run assignments
- PM/overhaul activities
- Compliance status
- Cost compliance
- Report generation
- Simulation reports
- Email notifications

### Fases de Deploy (Página 4-5)
- Phase 1: Mileage management + run assignments
- Phase 2: Costing
- Phase 3: Fleet expansion + competence management

---

## Estrutura do Documento

### 1. Visão do Produto
- Conceito "Single Pane of Glass" para manutenção de frotas
- Metáfora Google Earth (Semantic Zoom) - níveis de detalhe por zoom
- Como resolve cada dor do RFQ

### 2. Moodboard Visual
Incluir `<img>` tags com referências reais de:
- **Kepler.gl** (deck.gl showcase) - visualização de dados
- **Linear app** - timeline moderna e interativa
- **Railfleet/Railnova** - referência do setor ferroviário
- **Enterprise dashboards** (dark mode) - padrão visual moderno
- **Gantt charts modernos** - visualização de tarefas

### 3. Matriz Problema → Solução Visual
Para CADA dor do RFQ:
| # | Dor do Cliente | Solução na Demo | Componente/Tela |

### 4. Design System
- **Paleta de cores**: Dark mode enterprise (slate/zinc base)
- **Cores semânticas**: Success, Warning, Danger, Info
- **Tipografia**: Inter ou SF Pro (system font)
- **Gradiente heatmap**: Yellow → Orange → Red
- **Espaçamento**: 8px grid system

### 5. Especificação de Telas (para implementação)

#### 5.1 Dashboard Principal
- KPIs: Fleet availability, Mileage compliance, Resource utilization
- Alertas: Overrun/Underrun warnings
- Quick actions: Navigation links

#### 5.2 Timeline Interativa (Semantic Zoom)
**Conceito**: Canvas infinito com zoom semântico - informação muda conforme zoom

**MACRO View (zoom < 0.5x)**
- Visão 10-20 anos
- Heatmap de densidade de tarefas
- Cores: saturação de capacidade

**MESO View (0.5x - 2x)**
- Visão 2-5 anos
- Task blocks coloridos por tipo
- Indicadores de conflito

**MICRO View (zoom > 2x)**
- Visão 4-8 semanas
- Cards detalhados com labels
- Linhas de dependência

#### 5.3 Painel de Recursos
- Track allocation
- Man-hours disponíveis vs utilizados
- Spare parts status

#### 5.4 Modo Simulação (What-If)
- Baseline vs Scenario
- Delta metrics
- Ajuste de constraints

#### 5.5 Reports
- PDF/Excel export mockup
- Compliance reports
- Cost forecasting

### 6. Componentes UI (para implementação)

| Componente | Propósito | Notas de Implementação |
|------------|-----------|------------------------|
| `Navbar` | Navegação global | Logo, menu, user |
| `Sidebar` | Lista de trens | Scroll sync com canvas |
| `TimelineHeader` | Datas/períodos | Adaptive granularity |
| `DeckCanvas` | Visualização principal | deck.gl OrthographicView |
| `Minimap` | Navegação rápida | Bird's eye view |
| `TaskTooltip` | Hover info | Posição dinâmica |
| `TaskDetails` | Seleção | Drawer panel |
| `KPICard` | Métricas | Dashboard widgets |
| `AlertBanner` | Warnings | Overrun/compliance |

### 7. Interações

| Interação | Comportamento | deck.gl API |
|-----------|---------------|-------------|
| Pan | Drag para mover | OrthographicController |
| Zoom | Scroll para zoom | onViewStateChange |
| Hover | Highlight task | pickingInfo |
| Click | Selecionar task | onClick handler |
| Double-click | Zoom in | Animated transition |

### 8. Dados Mock

```typescript
// Estrutura de dados para mocks
interface Train {
  id: string;          // "ALT-001" ou "KNK-001"
  type: 'ALSTOM' | 'KINKI';
  currentMileage: number;
  status: 'operational' | 'maintenance' | 'out-of-service';
}

interface Task {
  id: string;
  trainId: string;
  startDate: string;   // ISO 8601
  endDate: string;
  type: 'A-Check' | 'B-Check' | 'C-Check' | 'D-Overhaul';
  manHours: number;
  track: number;
  hasConflict: boolean;
}

// Gerar: 128 trens × 12 anos × ~10 tasks/ano = ~15,000 tasks
```

### 9. Performance Targets

| Métrica | Target |
|---------|--------|
| FPS idle | ≥60 |
| FPS interaction | ≥30 |
| Initial load | <3s |
| Bundle size | <500KB gzipped |

---

## Referências Visuais para Moodboard

### deck.gl Showcase
- `https://deck.gl/images/showcase/kepler-gl.jpg` - Kepler.gl interface
- `https://deck.gl/images/showcase/flowmap.jpg` - Flow visualization
- `https://deck.gl/images/showcase/sanddance.jpg` - SandDance (Microsoft)

### Timeline/Gantt
- Linear app (linear.app) - modern timeline
- Frappe Gantt - open source reference
- Carbon Design System gantt patterns

### Enterprise Dashboard
- Dribbble dark mode dashboards
- Figma enterprise templates
- IBM Carbon Design System

### Ferroviário
- Railnova/Railfleet - competitor reference
- ZEDAS Asset - maintenance planning

---

## Arquivo a Criar

| Arquivo | Propósito |
|---------|-----------|
| `docs/DESIGN_SPEC.md` | Especificação completa para implementação |

---

## Fonte de Referência (ÚNICA)

- **`docs/RFQ.md`** - Requisitos do cliente (fonte única de verdade)
- **Web research** - Referências visuais e melhores práticas

---

## Próximos Passos

1. ✅ Definir estrutura do documento
2. Criar `docs/DESIGN_SPEC.md`
3. Popular seção de Moodboard com `<img>` tags
4. Detalhar cada tela com specs de implementação
5. Incluir mockup de dados
6. Atualizar `claude-progress.txt`
