# Plano: Refatoração Arquitetural do Canvas para UX/QA

**Objetivo:** Transformar o canvas de um protótipo funcional em um componente de produto com qualidade profissional, onde a navegação e alinhamento correspondem às expectativas de UX/QA.

**Escopo:** Correção arquitetural completa - não patches pontuais.

---

## Resumo Executivo

| Item | Antes | Depois |
|------|-------|--------|
| Alinhamento | Tarefas não correspondem aos trens na sidebar | TRAIN-001 = primeira linha de tarefas |
| Navegação | Arrasta infinitamente | Limitado aos bounds do mundo (50 trens × 10 anos) |
| Zoom | Escala sem centro | Centraliza no cursor (padrão Figma/Maps) |
| Posição inicial | Centro do mundo vazio | Canto superior-esquerdo (primeiro dado visível) |

**Arquivos principais:** `InfiniteCanvas.tsx` (refatoração completa), `types.ts` (WorldBounds)

---

## Diagnóstico dos Problemas

### Problema 1: Sistema de Coordenadas Desalinhado

**Código atual no MesoLayer.tsx:**
```javascript
const y = -task.trainIndex * pxPerTrain - pxPerTrain / 2;
// trainIndex 0 → Y = -12 (centro da linha)
// trainIndex 1 → Y = -36
```

**Código atual no App.tsx (Sidebar):**
```javascript
const sidebarOffset = -panY * zoom;
// panY = 0 → sidebar mostra TRAIN-001 no topo
```

**Código atual no InfiniteCanvas.tsx:**
```javascript
<OrthographicCamera position={[cameraPos.x, cameraPos.y, 100]} />
// cameraPos.y = 0 → câmera centrada em Y=0
// MAS trainIndex 0 está em Y=-12, não Y=0!
```

**Consequência:** A câmera no centro Y=0 não corresponde ao topo da sidebar onde está TRAIN-001.

### Problema 2: Navegação Sem Limites

O canvas pode ser arrastado infinitamente. Produtos profissionais (Google Maps, Figma, etc.) limitam a navegação ao conteúdo existente.

### Problema 3: Experiência Amadora

- Zoom não centraliza no cursor (F106 incompleto)
- Não há indicação visual do mundo navegável
- Pan permite sair completamente da área de dados

---

## Arquitetura Proposta

### Conceito: World Bounds

Definir um "mundo" com limites baseados nos dados:
- **X**: 0 até `totalDays * pxPerDay` (10 anos = 3650 dias = 36500px)
- **Y**: 0 até `-trainCount * pxPerTrain` (50 trens = -1200px)

A câmera será limitada a mostrar apenas conteúdo dentro desses bounds.

### Sistema de Coordenadas Unificado

```
TRAIN-001 (index 0) → Y = 0 até -24px
TRAIN-002 (index 1) → Y = -24 até -48px
...
TRAIN-050 (index 49) → Y = -1176 até -1200px

Dia 1 → X = 0 até 10px
Dia 2 → X = 10 até 20px
...
```

A câmera inicia posicionada para mostrar o canto superior esquerdo (X=0, Y=0).

---

## Arquivos a Modificar

| Arquivo | Mudanças |
|---------|----------|
| `apps/canvas/src/data/types.ts` | Adicionar `WorldBounds` interface |
| `apps/canvas/src/canvas/InfiniteCanvas.tsx` | Refatorar câmera com bounds, posição inicial, zoom no cursor |
| `apps/canvas/src/canvas/layers/MesoLayer.tsx` | Ajustar sistema Y (0 = topo, negativo = baixo) |
| `apps/canvas/src/App.tsx` | Ajustar sincronização sidebar |

---

## Implementação Detalhada

### Fase 1: Definir World Bounds (types.ts)

```typescript
export interface WorldBounds {
  minX: number;  // 0
  maxX: number;  // totalDays * pxPerDay
  minY: number;  // -trainCount * pxPerTrain
  maxY: number;  // 0
}
```

### Fase 2: Refatorar InfiniteCanvas

1. **Calcular bounds do mundo baseado nos dados**
2. **Posicionar câmera inicial no canto superior-esquerdo**
3. **Limitar pan aos bounds**
4. **Implementar zoom no cursor (F106)**

```typescript
// Câmera inicial mostra o canto superior-esquerdo
const initialCameraPos = {
  x: viewportWidth / 2 / zoom,  // Metade da viewport à direita de X=0
  y: -viewportHeight / 2 / zoom  // Metade da viewport abaixo de Y=0
};

// Clamp camera aos bounds
const clampedX = Math.max(minX + halfViewX, Math.min(maxX - halfViewX, x));
const clampedY = Math.max(minY + halfViewY, Math.min(maxY - halfViewY, y));
```

### Fase 3: Ajustar MesoLayer

Mudar o sistema de coordenadas Y para:
- Train 0 → Y de 0 a -24 (centro em -12)
- Train 1 → Y de -24 a -48 (centro em -36)

Isso já está correto. O problema é a posição inicial da câmera.

### Fase 4: Sincronizar Sidebar

A sidebar deve refletir exatamente quais trens estão visíveis no viewport da câmera.

```typescript
// Em App.tsx
const visibleTrainStart = Math.floor(-cameraY / pxPerTrain);
const sidebarOffset = cameraY * zoom;
```

---

## Ordem de Execução

1. [ ] **types.ts** - Adicionar WorldBounds
2. [ ] **InfiniteCanvas.tsx** - Refatorar completamente:
   - Calcular world bounds dos dados
   - Posição inicial da câmera (canto superior-esquerdo)
   - Pan com limites (clamp aos bounds)
   - Zoom centralizado no cursor
3. [ ] **App.tsx** - Ajustar sincronização sidebar
4. [ ] **MesoLayer.tsx** - Verificar se precisa ajuste (provavelmente não)
5. [ ] **Teste visual** - Playwright MCP
6. [ ] **Atualizar harness** - features.json, claude-progress.txt

---

## Critérios de Sucesso (QA Checklist)

- [ ] TRAIN-001 na sidebar alinha com a primeira linha de tarefas no canvas
- [ ] Ao arrastar, o canvas para quando atinge os limites dos dados
- [ ] Zoom centraliza no ponto do cursor
- [ ] Posição inicial mostra o primeiro trem e as primeiras tarefas
- [ ] Não é possível arrastar para áreas sem dados (espaço vazio)
- [ ] Experiência de navegação fluida e profissional (comparável a Figma/Google Maps)

---

## Atualizações do Harness

### features.json

**F105** - Mudar `passes: false` (reabrir para correção):
- Nota: "Partial - blocks render but misaligned with sidebar. Needs architectural fix."

**F106** - Já está `passes: false`:
- Nota atualizada: "Will be fixed as part of F105 architectural refactor."

### claude-progress.txt

Adicionar seção de sessão documentando:
1. Problema identificado: alinhamento e navegação
2. Decisão: refatoração arquitetural (não patch)
3. Mudanças feitas
4. Resultado dos testes visuais

---

## Notas Técnicas

### OrthographicCamera em R3F

A OrthographicCamera em Three.js/R3F tem:
- `position`: onde a câmera está no mundo
- `zoom`: quanto do mundo é visível (maior zoom = menos mundo visível)
- O frustum é calculado baseado no tamanho do container e zoom

Para uma viewport de 800x600 com zoom 1:
- Visível em X: position.x ± 400
- Visível em Y: position.y ± 300

### Fórmula de Zoom no Cursor

```typescript
// Antes do zoom
const worldX = (cursorX - viewportWidth/2) / oldZoom + cameraX;
const worldY = (cursorY - viewportHeight/2) / oldZoom + cameraY;

// Depois do zoom
const newCameraX = worldX - (cursorX - viewportWidth/2) / newZoom;
const newCameraY = worldY - (cursorY - viewportHeight/2) / newZoom;
```

Isso mantém o ponto sob o cursor fixo durante o zoom.
