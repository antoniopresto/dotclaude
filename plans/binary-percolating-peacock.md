# Plano: mms-poc - Prova de Conceito das Features Visuais

## Objetivo
Criar uma POC (Proof of Concept) chamada `mms-poc` que demonstre a viabilidade de implementar as features visuais do projeto MMS Fractal Canvas.

## Features Visuais a Demonstrar

### 1. Fractal Canvas com Zoom Semântico
- Canvas principal com zoom contínuo de 10% a 100%
- Transições suaves entre níveis de zoom
- Performance <100ms nas operações

### 2. Nível Estratégico (Zoom 10%)
- Heatmap de capacidade com grid anos x tipos de frota
- Codificação de cores (verde = OK, vermelho = breach)
- Drag & drop de blocos de overhaul

### 3. Nível Tático (Zoom 50%)
- Colunas mensais com gráficos de barras empilhadas
- Man-hours disponíveis vs requeridos
- Alertas visuais amarelos para conflitos

### 4. Nível Operacional (Zoom 100%)
- Cápsulas de trens com ID visível
- Barras de progresso de quilometragem
- Pistas/trilhos como lanes
- Drag de trens entre rotas

### 5. Constraint Deck (Sidebar)
- Controles contextuais por nível de zoom
- Sliders e toggles interativos

### 6. Animações e Feedback Visual
- Bounce-back para ações inválidas
- Transições animadas
- HUD de custo em tempo real

---

## Stack Tecnológico da POC

| Camada | Tecnologia | Justificativa |
|--------|------------|---------------|
| Framework | Vite + React 18 | Build rápido, HMR eficiente |
| Linguagem | **JavaScript** | Agilidade na POC |
| Visualização | **Three.js** | WebGL high-perf, 60fps garantido |
| Layout/Zoom | **D3.js** | Escalas, layouts, zoom behavior |
| State | Zustand | Leve, simples, performático |
| UI Base | Tailwind CSS | Estilização rápida |

### Por que Three.js + D3?

**Three.js (WebGL):**
- Renderização GPU-accelerated
- 128 trens + animações a 60fps sem problema
- Zoom/pan com performance <100ms garantida
- Raycasting para detecção de cliques/hover
- Perfeito para o requisito "Zero Latency"

**D3.js:**
- Cálculos de escala (linear, band, color)
- d3-zoom para controle de zoom/pan
- d3-drag para drag & drop
- Não renderiza DOM - apenas calcula posições
- Three.js renderiza o que D3 calcula

---

## Estrutura do Projeto

```
mms-poc/
├── index.html
├── package.json
├── vite.config.js
├── tailwind.config.js
├── postcss.config.js
├── src/
│   ├── main.jsx
│   ├── App.jsx
│   ├── index.css
│   ├── components/
│   │   ├── canvas/
│   │   │   ├── FractalCanvas.jsx      # Container React + Three.js scene
│   │   │   ├── StrategicView.js       # Heatmap cells (Three.js meshes)
│   │   │   ├── TacticalView.js        # Bar charts (Three.js meshes)
│   │   │   └── OperationalView.js     # Train capsules (Three.js meshes)
│   │   ├── sidebar/
│   │   │   ├── ConstraintDeck.jsx     # Sidebar container (React)
│   │   │   ├── StrategicControls.jsx  # Controles zoom 10%
│   │   │   ├── TacticalControls.jsx   # Controles zoom 50%
│   │   │   └── OperationalControls.jsx # Controles zoom 100%
│   │   └── hud/
│   │       └── CostHUD.jsx            # HUD flutuante (React overlay)
│   ├── three/
│   │   ├── scene.js                   # Three.js scene setup
│   │   ├── camera.js                  # Orthographic camera + zoom
│   │   ├── renderer.js                # WebGL renderer
│   │   ├── objects/
│   │   │   ├── HeatmapCell.js         # Mesh para célula do heatmap
│   │   │   ├── BarChart.js            # Mesh para barras
│   │   │   ├── TrainCapsule.js        # Mesh para trem (rect + text)
│   │   │   └── TrackLane.js           # Mesh para trilho
│   │   └── interactions/
│   │       ├── zoomController.js      # D3-zoom integrado com Three.js
│   │       ├── dragController.js      # D3-drag + raycasting
│   │       └── raycaster.js           # Detecção de hover/click
│   ├── d3/
│   │   ├── scales.js                  # Escalas D3 (linear, band, color)
│   │   ├── zoom.js                    # d3-zoom behavior
│   │   └── layouts.js                 # Cálculos de posição
│   ├── store/
│   │   ├── index.js                   # Store Zustand
│   │   ├── canvasStore.js             # Zoom, pan, viewport
│   │   ├── fleetStore.js              # Dados de 128 trens
│   │   └── scheduleStore.js           # Agendamentos
│   ├── data/
│   │   ├── mockTrains.js              # 128 trens (79 ALT + 49 KNK)
│   │   ├── mockSchedule.js            # Manutenções programadas
│   │   └── mockDepots.js              # Depots com recursos
│   └── utils/
│       ├── colors.js                  # Paleta de cores status
│       └── calculations.js            # Cálculos de mileage/capacity
```

---

## Plano de Implementação

### Fase 1: Setup do Projeto
```bash
# Criar projeto Vite + React (JavaScript)
npm create vite@latest mms-poc -- --template react
cd mms-poc

# Instalar dependências core
npm install three d3 zustand

# UI e estilos
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p
```

### Fase 2: Three.js Scene Base
1. `src/three/scene.js` - Scene, renderer, animation loop
2. `src/three/camera.js` - OrthographicCamera (2D view)
3. `src/components/canvas/FractalCanvas.jsx` - Monta scene no React

### Fase 3: D3 Zoom Integration
1. `src/d3/zoom.js` - d3.zoom() behavior
2. `src/three/interactions/zoomController.js` - Conecta D3 zoom → Three.js camera
3. `src/d3/scales.js` - Escalas para posicionamento

### Fase 4: Mock Data + Store
1. `src/data/mockTrains.js` - 128 trens (ALT-001..079, KNK-001..049)
2. `src/store/canvasStore.js` - zoom level, pan, semantic level
3. `src/store/fleetStore.js` - dados dos trens

### Fase 5: Visão Estratégica (Zoom 10%)
1. `src/three/objects/HeatmapCell.js` - PlaneGeometry + MeshBasicMaterial
2. `src/components/canvas/StrategicView.js` - Grid 12 anos x 2 frotas
3. Cores via D3 scale: verde → amarelo → vermelho
4. Drag via raycasting + d3-drag

### Fase 6: Visão Tática (Zoom 50%)
1. `src/three/objects/BarChart.js` - BoxGeometry para barras
2. `src/components/canvas/TacticalView.js` - 12 colunas mensais
3. Stacked bars: man-hours required vs available
4. Alertas amarelos como glow/outline

### Fase 7: Visão Operacional (Zoom 100%)
1. `src/three/objects/TrainCapsule.js` - Rect + TextGeometry + progress bar
2. `src/three/objects/TrackLane.js` - Linhas horizontais
3. Drag de trens entre lanes via raycaster
4. Cor muda conforme mileage risk

### Fase 8: Sidebar React (Constraint Deck)
1. `src/components/sidebar/ConstraintDeck.jsx` - Overlay React
2. Controles diferentes por semantic level
3. Sliders que atualizam store Zustand

### Fase 9: HUD + Polish
1. `src/components/hud/CostHUD.jsx` - Overlay flutuante
2. Animações com TWEEN.js ou requestAnimationFrame
3. Bounce-back via spring physics

---

## Critérios de Sucesso

- [ ] Zoom semântico funcional entre 3 níveis
- [ ] Drag & drop em todos os níveis
- [ ] Transições suaves <100ms
- [ ] Feedback visual para ações
- [ ] Sidebar contextual funcionando
- [ ] Dados mock de 128 trens renderizados
- [ ] Heatmap com cores de status
- [ ] Bar charts de workload
- [ ] Train capsules com mileage bars

---

## Arquivos Críticos (ordem de criação)

1. `mms-poc/src/three/scene.js` - Setup Three.js base
2. `mms-poc/src/three/camera.js` - Câmera ortográfica
3. `mms-poc/src/d3/zoom.js` - D3 zoom behavior
4. `mms-poc/src/three/interactions/zoomController.js` - Integração D3↔Three
5. `mms-poc/src/data/mockTrains.js` - 128 trens mock
6. `mms-poc/src/store/canvasStore.js` - Estado zoom/pan/semantic
7. `mms-poc/src/components/canvas/FractalCanvas.jsx` - Container React
8. `mms-poc/src/three/objects/TrainCapsule.js` - Mesh de trem
9. `mms-poc/src/components/sidebar/ConstraintDeck.jsx` - Sidebar React

---

## Dependências npm

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "three": "^0.160.0",
    "d3": "^7.8.5",
    "zustand": "^4.5.0"
  },
  "devDependencies": {
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0",
    "@vitejs/plugin-react": "^4.2.0",
    "vite": "^5.0.0"
  }
}
```
