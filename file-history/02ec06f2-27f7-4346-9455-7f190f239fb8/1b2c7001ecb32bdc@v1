# Plano: Evolução BMAD + Novos Agents Especializados

## Contexto

**Objetivo:** Integrar as sugestões do Gemini (Context Sharding, Knowledge Structure) com os perfis profissionais críticos do MMS_PROFESSIONAL_PROFILES.md, criando agents especializados para OR (Operations Research) e Data Engineering.

**Análise:**
- BMAD implementado tem 10 agents (8 BMM + 2 custom)
- Gemini sugere: Context Sharding, Knowledge reorganization, Railway Expert melhorado
- Perfis críticos faltantes: OR Specialist (120h), Data Engineer (80h)
- Railway Expert atual cobre domínio mas falta "Non-Negotiable Constraints"

---

## Plano de Implementação

### Fase 1: Reorganizar Knowledge Structure (Gemini Suggestion)

**Ação:** Reestruturar `bmad-knowledge/` para Context Sharding

```
bmad-knowledge/
├── domain/                    # Agentes de domínio leem aqui
│   ├── glossary.md           # ✅ Já existe
│   ├── entities.md           # CRIAR: Extrair §2.2-2.3 do Playbook
│   ├── unknown-unknowns.md   # CRIAR: Extrair §2.4 (CRÍTICO)
│   └── constraints.md        # CRIAR: Hard/soft constraints
│
├── technical/                 # Architect, DEV, OR leem aqui
│   ├── solver-research.md    # CRIAR: Extrair de OLD_LEGACY_RESEARCH.md
│   ├── architecture.md       # CRIAR: Extrair §8 do Playbook
│   └── data-model.md         # CRIAR: Especificações de dados
│
├── business/                  # PM, Demo Coordinator leem aqui
│   ├── rfq-requirements.md   # CRIAR: Converter RFQ.pdf para MD
│   ├── demo-script.md        # CRIAR: Extrair §12 do Playbook
│   └── success-metrics.md    # CRIAR: KPIs e critérios de sucesso
│
└── decisions/
    └── adr/                   # ✅ Já existe (vazio)
```

**Benefício:** Cada agent lê apenas contexto relevante, evitando alucinações.

---

### Fase 2: Criar OR Specialist Agent (CRÍTICO - 120h no projeto)

**Arquivo:** `_bmad/custom/agents/or-specialist.agent.md`

**Perfil:**
- Nome: Otto
- Título: Operations Research Specialist
- Expertise: CP-SAT, OR-Tools, constraint modeling, metaheuristics

**Workflows:**
| Trigger | Descrição |
|---------|-----------|
| `*model-problem` | Modelar problema de otimização |
| `*implement-solver` | Implementar solver CP-SAT |
| `*tune-solver` | Otimizar parâmetros e performance |
| `*generate-justifications` | Criar explicações para recomendações |
| `*handle-infeasibility` | Tratar casos sem solução |

**Critical Constraints (Non-Negotiable):**
1. Wheelset wear não é linear - peso por perfil de rota
2. Shunting = 15-30 min + €350 - nunca assumir instantâneo
3. Depot deadlocks - usar cycle detection
4. Pit occupancy "Tetris" - restrição espacial, não apenas recurso
5. Solver timeout fallback - sempre ter heurística greedy

**Context Sources:**
- `_bmad/knowledge/technical/solver-research.md`
- `_bmad/knowledge/domain/constraints.md`

---

### Fase 3: Criar Data Engineer Agent (ALTA - 80h no projeto)

**Arquivo:** `_bmad/custom/agents/data-engineer.agent.md`

**Perfil:**
- Nome: Diego
- Título: Senior Data Engineer
- Expertise: PostgreSQL, TimescaleDB, CQRS, Event Sourcing, Seed Data

**Workflows:**
| Trigger | Descrição |
|---------|-----------|
| `*design-data-model` | Desenhar modelo de dados |
| `*create-migrations` | Criar migrations SQL |
| `*generate-seed-data` | Gerar dados realistas para demo |
| `*setup-timescale` | Configurar TimescaleDB para time-series |
| `*validate-data-quality` | Validar qualidade dos dados |

**Critical Data Rules:**
1. Usar DECIMAL(12,2) para km - nunca float
2. Mileage history como log imutável - nunca UPDATE
3. Temporal versioning - valid_from/valid_to em todas entidades
4. Nomes realistas - "UTE-3400-012", nunca "Train 1"
5. Seed "problemático" - 22% variance para mostrar solução

**Context Sources:**
- `_bmad/knowledge/technical/data-model.md`
- `_bmad/knowledge/domain/entities.md`

---

### Fase 4: Melhorar Railway Expert (Gemini Suggestion)

**Ação:** Adicionar seção "Critical Constraints (Non-Negotiable)" ao agent existente

**Constraints a adicionar:**
```markdown
# Critical Constraints (Non-Negotiable)
1. **Shunting:** Mover trem no pátio = 15-30 min. Planos que ignoram são INVÁLIDOS.
2. **Wheelsets:** Desgaste NÃO é linear. Curvas degradam mais que retas.
3. **Consist:** "Married pairs" NUNCA se separam.
4. **Dead Running:** Mover trem vazio custa €350. DEVE ser minimizado.
5. **Fitness Window:** PM antes de exceder intervalo + 10% tolerância.
6. **Depot Capacity:** Red Line max 30, Green Line max 25.
7. **Night Window:** Manutenção apenas 01:00-04:30 (3.5h).
```

**Adicionar referência obrigatória:**
```markdown
# Context Sources
- SEMPRE ler `_bmad/knowledge/domain/unknown-unknowns.md` antes de responder.
```

---

### Fase 5: Configurar PM como "Scope Guardian" (Gemini Suggestion)

**Ação:** Adicionar regra ao PM agent para rejeitar features fora do escopo

**Adicionar em pm.agent.md:**
```markdown
# Scope Protection Rule
Se o usuário pedir features fora do `prd.md`:
- Integração real com SAP/Maximo (só mock na demo)
- App Mobile (só web responsivo)
- Multi-tenant (single tenant na demo)
- Histórico > 6 meses (só 6 meses de seed)

REJEITAR educadamente citando o prazo de 12 semanas.
Referência: MMS_DEMO_PLAYBOOK.md §4.5-4.6 (Out of Scope)
```

---

### Fase 6: Criar Knowledge Files (Context Sharding)

**Arquivos a criar:**

| Arquivo | Fonte | Conteúdo |
|---------|-------|----------|
| `domain/entities.md` | Playbook §2.2-2.3 | Trains, Depots, Services, Maintenance |
| `domain/unknown-unknowns.md` | Playbook §2.4 | Wheelsets, Bogies, Crew, Shunting |
| `domain/constraints.md` | Playbook §8.4 + Research | Hard/soft constraints |
| `technical/solver-research.md` | OLD_LEGACY_RESEARCH.md | Técnicas, case studies |
| `technical/architecture.md` | Playbook §8 | Stack, integração |
| `business/rfq-requirements.md` | RFQ.pdf | Requisitos do cliente |
| `business/demo-script.md` | Playbook §12 | Script 15 min |

---

## Arquivos a Modificar/Criar

### Criar (Novos)
1. `_bmad/custom/agents/or-specialist.agent.md` - Agent OR
2. `_bmad/custom/agents/data-engineer.agent.md` - Agent Data
3. `bmad-knowledge/domain/entities.md` - Entidades do domínio
4. `bmad-knowledge/domain/unknown-unknowns.md` - Constraints críticos
5. `bmad-knowledge/domain/constraints.md` - Hard/soft constraints
6. `bmad-knowledge/technical/solver-research.md` - Pesquisa OR
7. `bmad-knowledge/technical/architecture.md` - Stack técnico
8. `bmad-knowledge/business/rfq-requirements.md` - RFQ em MD
9. `bmad-knowledge/business/demo-script.md` - Script demo

### Modificar (Existentes)
1. `_bmad/custom/agents/railway-domain-expert.agent.md` - Adicionar Non-Negotiable
2. `_bmad/bmm/agents/pm.agent.md` - Adicionar Scope Guardian
3. `_bmad/project-context.md` - Adicionar novos agents
4. `_bmad/bmm-workflow-status.yaml` - Atualizar status

---

## Ordem de Execução

1. **Criar estrutura de pastas** para knowledge/
2. **Criar OR Specialist agent** (mais crítico)
3. **Criar Data Engineer agent**
4. **Melhorar Railway Expert** com non-negotiable constraints
5. **Melhorar PM** com scope protection
6. **Criar knowledge files** (context sharding)
7. **Atualizar project-context.md** e workflow-status

---

## Validação

Após implementação, verificar:
- [ ] OR Specialist tem todos os workflows
- [ ] Data Engineer tem todos os workflows
- [ ] Railway Expert tem Non-Negotiable Constraints
- [ ] PM tem Scope Protection
- [ ] Knowledge structure reorganizada
- [ ] Todos os agents seguem padrão consistente
- [ ] project-context.md atualizado

---

## Estimativa

- Novos agents: ~30 min (OR + Data)
- Melhorias: ~15 min (Railway + PM)
- Knowledge files: ~45 min (extrair e formatar)
- Total: ~1.5 horas

---

*Plano criado: 2025-12-28*
*Baseado em: Gemini review + MMS_PROFESSIONAL_PROFILES.md + BMAD V6*
