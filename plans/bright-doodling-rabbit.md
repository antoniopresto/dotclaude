# MMS Demo - Plano de Reimplementação Completa

**Data:** 2025-12-20
**Status:** PLANEJAMENTO
**Prioridade:** Qualidade Máxima

---

## DESCOBERTAS DA ANÁLISE (3 dias de conversas)

### 1. Problemas Identificados

| Tipo | Problema | Impacto |
|------|----------|---------|
| Context Loss | 91% do claude-progress.txt perdido | Alto |
| Context Loss | 64% do features.json perdido | Alto |
| Hallucination | DESIGN_SPEC.md diz "Astro.js" → deveria ser "Vite + React 18" | Crítico |
| Hallucination | Referências geospatial baixadas em vez de Gantt/Timeline | Médio |
| Incomplete | Sandbox Mode subdescrito (feature primária) | Crítico |

### 2. Imagens de Referência

**IRRELEVANTES (1/5) - Baixadas erroneamente:**
- `deckgl/kepler-gl.jpg` → Mapa geospatial
- `deckgl/flowmap.jpg` → Fluxo de rede
- `deckgl/sanddance.jpg` → Estatísticas 3D
- `deckgl/avs.jpg` → Visualização automotiva
- `linear/linear-*.png` → Páginas marketing
- `railway/railnova-railfleet.png` → Splash page

**RELEVANTES (4-5/5):**
- `scheduling/dhtmlx-gantt-*.png` (3 arquivos) → EXCELENTES
- `islands-ui/jetbrains-fleet-islands.png` → BOM layout
- `islands-ui/gitkraken-interface.png` → BOM densidade

**A BUSCAR:**
- Epicflow What-If: https://www.epicflow.com/features/what-if/
- Epicflow Pipeline: https://www.epicflow.com/wp-content/uploads/2023/10/pipeline-implement.png
- Dime Scheduler: https://www.dimescheduler.com/
- AVS Auto Demo: https://avs.auto/demo/index.html
- DHTMLX Gantt D3: https://dhtmlx.github.io/demo-gantt-d3/index_1.html

### 3. POCs Funcionais Existentes

| POC | Localização | Status |
|-----|-------------|--------|
| XState Viewport | `stories/01-POCs/State/XStateViewport.stories.tsx` | ✅ |
| Semantic Zoom | `stories/01-POCs/Rendering/SemanticZoom.stories.tsx` | ✅ |
| Time Scrubber (7 variantes) | `stories/01-POCs/TimeScrubber/` | ✅ |
| Viewport Machine | `stories/machines/viewport.machine.ts` | ✅ |
| Mock Data Generator | `stories/data/mock-generator.ts` | ✅ |
| Semantic Zoom POC HTML | `design/reference/semantic-zoom-poc.html` | ✅ (gold standard) |

### 4. Stack Correto

```
Framework:     Vite 5.x + React 18.3.1 + TypeScript
UI Library:    BlueprintJS 6.1.0
Visualization: deck.gl 9.2.5 com OrthographicView
State:         XState 5.x + @xstate/react 6.x
Styling:       Tailwind CSS
```

### 5. Decisões do Usuário (Confirmadas 2025-12-20)

- **Código atual**: Mover para `apps/canvas-old/` (referência apenas)
- **Prioridades demo**: Semantic Zoom + Visual Polish + Sandbox Mode Toggle
- **Deadline**: Qualidade máxima, tempo necessário
- **Tech Stack**: Vite + React 18 (NÃO Astro.js)
- **Source of Truth**: APENAS `docs/RFQ.md`

---

## PROTOCOLO HARNESS (OBRIGATÓRIO)

### Antes de QUALQUER tarefa:
1. Registrar tarefa em `claude-progress.txt`
2. Registrar orientações permanentes em `CLAUDE.md`
3. Commit WIP se houver código

### Durante tarefas:
1. Salvar a cada subtask completada
2. Checkpoint a cada 15-20 minutos
3. Se contexto > 70%, PARAR e salvar

### Após tarefas:
1. Atualizar `claude-progress.txt`
2. Atualizar `features.json`
3. Commit com mensagem descritiva

---

## PLANO DE EXECUÇÃO

### FASE 0: Preparação Harness (PRIMEIRO!)

**Arquivos a modificar:**

1. `claude-progress.txt` - Adicionar:
   - Descobertas da análise de 3 dias
   - Decisões do usuário confirmadas
   - Plano de reimplementação

2. `CLAUDE.md` - Adicionar seção:
   ```markdown
   ## REIMPLEMENTAÇÃO 2025-12-20

   ### Contexto
   - Código atual em `apps/canvas-old/` (referência apenas, não funciona)
   - Nova implementação em `apps/canvas/` do zero
   - Source of Truth: APENAS docs/RFQ.md

   ### Prioridades Demo
   1. Semantic Zoom (MACRO→MESO→MICRO) funcionando perfeitamente
   2. Visual Polish enterprise (dark theme, BlueprintJS, Linear aesthetic)
   3. Sandbox Mode Toggle (LIVE/SANDBOX com diferenciação violet)

   ### Stack
   - Vite 5.x + React 18.3.1
   - deck.gl 9.2.5 (OrthographicView)
   - XState 5.x + @xstate/react 6.x
   - BlueprintJS 6.1.0
   - Tailwind CSS
   ```

3. `features.json` - Atualizar com nova estrutura de features

**Validação:** Git diff mostra alterações, commit criado

---

### FASE 1: Arquivar e Criar Projeto

**Tarefas:**
1. `mv apps/canvas apps/canvas-old`
2. Criar novo projeto Vite + React 18 em `apps/canvas`
3. Instalar dependências:
   ```bash
   bun add @deck.gl/core @deck.gl/layers @deck.gl/react
   bun add xstate @xstate/react
   bun add @blueprintjs/core @blueprintjs/icons
   bun add tailwindcss postcss autoprefixer
   ```

**Arquivos a criar:**
- `apps/canvas/index.html`
- `apps/canvas/vite.config.ts`
- `apps/canvas/tailwind.config.js`
- `apps/canvas/src/main.tsx`
- `apps/canvas/src/App.tsx`
- `apps/canvas/src/index.css`

**Validação:** `bun run dev` abre página em branco, sem erros

---

### FASE 2: Foundation (Layout + State)

**Copiar de apps/canvas-old/:**
- `stories/machines/viewport.machine.ts` → `src/state/viewport.machine.ts`
- `stories/data/mock-generator.ts` → `src/data/generator.ts`
- `stories/data/mock-config.ts` → `src/data/config.ts`

**Arquivos a criar:**
- `src/state/sandbox.machine.ts` - Máquina LIVE/SANDBOX
- `src/state/index.ts` - Re-exports
- `src/data/types.ts` - Tipos TypeScript
- `src/components/Layout.tsx` - Islands UI shell
- `src/components/Navbar.tsx` - BlueprintJS navbar
- `src/components/Sidebar.tsx` - Lista de trens

**Validação:** Layout básico renderiza, sidebar mostra lista de trens

---

### FASE 3: Semantic Zoom

**Arquivos a criar:**
- `src/canvas/DeckCanvas.tsx` - Wrapper deck.gl
- `src/canvas/layers/MacroLayer.ts` - Heatmap (zoom < 0.5)
- `src/canvas/layers/MesoLayer.ts` - Task blocks (0.5 - 2.0)
- `src/canvas/layers/MicroLayer.ts` - Detailed cards (zoom > 2.0)
- `src/canvas/layers/index.ts` - LOD orchestrator

**Referências:**
- `design/reference/semantic-zoom-poc.html` - Algoritmo de crossfade
- `apps/canvas-old/stories/01-POCs/Rendering/SemanticZoom.stories.tsx`

**Validação:**
- Zoom suave de 0.1x a 5.0x
- Transições LOD sem flickering
- 60fps durante pan/zoom

---

### FASE 4: Visual Polish

**Arquivos a criar/modificar:**
- `src/index.css` - Tema dark completo
- `src/components/TimelineHeader.tsx` - Datas adaptativas
- `src/components/Minimap.tsx` - Overview navigator
- `src/components/TaskTooltip.tsx` - Hover details

**Design System:**
```css
--bg-primary: #0D0D0D;
--bg-secondary: #1A1A1A;
--text-primary: #FFFFFF;
--text-secondary: #A3A3A3;
--accent-sandbox: #8B5CF6; /* Violet */
```

**Validação:**
- Visual comparável a Linear/JetBrains Fleet
- Dark theme consistente
- Tipografia legível em todos os LODs

---

### FASE 5: Sandbox Mode

**Arquivos a criar:**
- `src/state/sandbox.machine.ts` - XState LIVE↔SANDBOX
- `src/components/SandboxToggle.tsx` - Botão toggle
- `src/components/SandboxPanel.tsx` - Delta metrics
- `src/hooks/useSandboxMode.ts` - Hook de estado

**Comportamento:**
- LIVE: Background #0D0D0D, read-only
- SANDBOX: Background #1E1B2E (violet-tinted), editable, violet accent

**Validação:**
- Toggle funciona
- Cores mudam visivelmente
- Estado persiste durante navegação

---

### FASE 6: Polish Final

**Tarefas:**
- Performance profiling
- RBush spatial index para hover
- Testes visuais com Playwright MCP
- Correção de bugs

**Validação:**
- 60fps idle, 30fps durante interação
- Zero erros no console
- Screenshots aprovados

---

## ARQUIVOS CRÍTICOS

### Para Ler (Referência):
- `docs/RFQ.md` - Source of Truth
- `design/reference/semantic-zoom-poc.html` - Algoritmo gold standard
- `apps/canvas-old/stories/machines/viewport.machine.ts` - XState POC

### Para Criar:
- `apps/canvas/src/App.tsx`
- `apps/canvas/src/canvas/DeckCanvas.tsx`
- `apps/canvas/src/state/viewport.machine.ts`
- `apps/canvas/src/state/sandbox.machine.ts`

### Para Atualizar:
- `claude-progress.txt` - Adicionar descobertas
- `CLAUDE.md` - Adicionar seção de reimplementação
- `features.json` - Nova estrutura

---

## PRÓXIMO PASSO IMEDIATO

**ANTES de qualquer código:**
1. Atualizar `claude-progress.txt` com descobertas
2. Atualizar `CLAUDE.md` com orientações permanentes
3. Commit: "docs(harness): prepare for complete reimplementation"

**DEPOIS:**
1. `mv apps/canvas apps/canvas-old`
2. Criar novo projeto
3. Seguir fases 1-6

---

*Plano criado em 2025-12-20*
*Contexto: Reimplementação completa após múltiplas tentativas falhas*
