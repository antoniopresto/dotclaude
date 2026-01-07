# Plano: Evolução POC → Produção (Continuous Beta)

## Referência: [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)

---

## Contexto

O URGENT_POC está completo com 4 páginas HTML estáticas que renderizam os designs.
Próximo passo: adicionar interatividade e migrar para stack de produção de forma incremental.

**Princípios**:
- Uma feature por sessão (harness protocol)
- Evitar complexidade do monorepo inicialmente
- CDN libs no HTML → Vite simples → Monorepo (quando necessário)
- CSS framework para reduzir verbosidade (Tailwind CDN)

---

## Atualizações no Harness

### 1. Adicionar ao `features.json` (novas features)

```json
{
  "id": "F015",
  "category": "poc",
  "description": "Fix layout.html proportions (scenario comparison view)",
  "steps": [
    "Ajustar altura das rows para proporcional ao design",
    "Corrigir espaçamento da conflict zone",
    "Verificar via screenshot"
  ],
  "passes": false,
  "blockedBy": "F000",
  "notes": "Proporções estavam distorcidas na imagem de referência"
},
{
  "id": "F016",
  "category": "poc",
  "description": "Add Tailwind CSS via CDN to POC pages",
  "steps": [
    "Adicionar Tailwind CDN ao head das páginas",
    "Migrar CSS inline para classes Tailwind",
    "Verificar consistência visual"
  ],
  "passes": false,
  "blockedBy": "F015",
  "notes": "Reduz verbosidade CSS, melhora eficiência LLM"
},
{
  "id": "F017",
  "category": "poc",
  "description": "Add pan/zoom interactivity to POC canvas",
  "steps": [
    "Implementar drag-to-pan no canvas",
    "Implementar scroll-to-zoom",
    "Transição de LOD (macro→meso→micro)",
    "Testar fluidez a 60fps"
  ],
  "passes": false,
  "blockedBy": "F016",
  "notes": "Usar eventos nativos do canvas, evitar libs pesadas"
},
{
  "id": "F018",
  "category": "poc",
  "description": "Add click/hover interactions on tasks",
  "steps": [
    "Hover highlight em task cards",
    "Click para selecionar task",
    "Tooltip com detalhes",
    "Keyboard navigation (Tab, Enter)"
  ],
  "passes": false,
  "blockedBy": "F017",
  "notes": "Priorizar acessibilidade"
},
{
  "id": "F019",
  "category": "migration",
  "description": "Migrate POC to simple Vite setup (when ready)",
  "steps": [
    "Criar projeto Vite standalone em URGENT_POC/vite/",
    "Portar HTML pages para componentes",
    "Manter independência do monorepo principal",
    "Validar build e HMR funcionando"
  ],
  "passes": false,
  "blockedBy": "F018",
  "notes": "Só migrar quando interatividade HTML estiver validada"
}
```

### 2. Adicionar ao `claude-progress.txt`

```markdown
## Próxima Sessão: Plan Approved

### Roadmap POC Interativo (Continuous Beta)
1. [F015] Fix layout.html proportions
2. [F016] Tailwind CSS via CDN
3. [F017] Pan/Zoom interactivity
4. [F018] Click/hover interactions
5. [F019] Migrate to Vite (quando pronto)

### Abordagem
- HTML + CDN primeiro (zero setup overhead)
- Uma feature por commit
- Screenshot verification após cada mudança
- Migrar para Vite apenas quando HTML ficar limitante
```

---

## Arquivos a Modificar

| Arquivo | Ação |
|---------|------|
| `URGENT_POC/layout.html` | Corrigir proporções |
| `URGENT_POC/*.html` | Adicionar Tailwind CDN, migrar CSS |
| `features.json` | Adicionar F015-F019 |
| `claude-progress.txt` | Adicionar roadmap |

---

## Ordem de Execução

1. **Sessão atual**: Corrigir `layout.html` proporções (F015)
2. **Próxima**: Tailwind CDN (F016)
3. **Depois**: Interatividade pan/zoom (F017)
4. **Depois**: Click/hover (F018)
5. **Quando pronto**: Vite migration (F019)

---

## Decisões Técnicas

### Por que CDN primeiro?
- Zero setup, teste imediato
- LLM pode focar em lógica, não em config
- Fácil rollback se algo falhar

### Por que Tailwind?
- Matches existing design system (zinc-100, blue-700, etc.)
- Classes curtas = menos tokens
- Familiar no projeto principal

### Quando migrar para Vite?
- Quando precisar de: imports, TypeScript, state management
- Ou quando HTML ficar muito grande para manter

---

## Validação R3F Existente (Paralelo)

As features F006-F011 do projeto principal ainda precisam de validação visual.
Isso pode ser feito em paralelo após o POC interativo estar funcional.
