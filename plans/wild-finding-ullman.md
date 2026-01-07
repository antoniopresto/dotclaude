# MMS Last Attempt - Plano de Extração de Conhecimento

## Situação Atual

### Descobertas da Exploração Inicial

**Localização do arquivo de conversas:**
- `/Users/anotonio.silva/antonio/mms/system/genesis/attempt6202/chats/conversations.jsonl`
- 6.9MB, 9304 linhas
- Estrutura: `{content, project, role, session}`

**Diretórios relevantes encontrados:**
| Diretório | Descrição |
|-----------|-----------|
| `mms/system/` | Tentativa mais recente - tem `.harness/` |
| `mms/MFC/` | Tentativa full-stack Next.js + Python |
| `mms/deck/` | Experimentos deck.gl |
| `mms/projects/` | Tentativas históricas |
| `mms/design/` | 9 mockups de referência |

### Conflitos Identificados (CRÍTICO)

| Arquivo | Diz | Bootstrap Instrução |
|---------|-----|---------------------|
| system/CLAUDE.md | BlueprintJS 6 | PatternFly v6 |
| system/CLAUDE.md | @zazcart/toolkit | @belt/tools |
| system/CLAUDE.md | React 18.3.1 | React 19 |

**Conclusão:** Os arquivos existentes estão DESATUALIZADOS. As instruções de bootstrap definem o stack CORRETO.

### Status do Harness Existente (system/.harness/)

- **Phase 0-1:** Completed (Harness Setup + Territory Mapping)
- **Phase 2:** IN PROGRESS - 0/8 extraction tasks done
- **Phase 3-8:** Pending

---

## Fase 1: Exploração (EM ANDAMENTO)

Lançar 3 agentes Explore em paralelo:

1. **Agent A - Conversations Analysis**
   - Analisar estrutura do conversations.jsonl
   - Extrair decisões de stack
   - Identificar padrões de falha

2. **Agent B - Existing Code Exploration**
   - Explorar system/apps/canvas/
   - Explorar MFC/apps/
   - Identificar código que funcionou

3. **Agent C - Previous Harness Review**
   - Ler system/.harness/progress.txt histórico
   - Ler MFC/claude-progress.txt (41KB!)
   - Extrair lições aprendidas

---

## Fase 2: Plano de Extração (APÓS EXPLORAÇÃO)

### Map-Reduce com Agentes Paralelos

**PHASE 1: MAP (4 agentes paralelos)**
- Agent A: Extract STACK decisions
- Agent B: Extract ARCHITECTURE decisions
- Agent C: Extract FAILURE patterns
- Agent D: Extract WORKING code

**PHASE 2: REDUCE (consolidação)**
- Merge findings
- Resolve conflicts
- Cross-reference with official docs

**PHASE 3: VALIDATE**
- Web search each technical decision
- Verify package versions (npm)
- Check compatibility

---

## Stack Correto (Conforme Bootstrap)

### FORBIDDEN (NÃO USAR)
- @blueprintjs/*
- @zazcart/*
- xstate
- next
- zustand/redux/mobx
- react@18
- useState/useRef/useEffect

### REQUIRED (USAR)
| Package | Version |
|---------|---------|
| react | 19.x |
| @patternfly/react-core | 6.x |
| @belt/tools | latest |
| @react-three/fiber | 9.x |
| @react-three/drei | 10.x |
| three | 0.170+ |
| vite | 6.x |

---

## Próximos Passos

1. [ ] Lançar agentes de exploração
2. [ ] Analisar resultados
3. [ ] Perguntar ao usuário sobre ambiguidades
4. [ ] Finalizar plano de extração

---

*Última atualização: 2026-01-06*
