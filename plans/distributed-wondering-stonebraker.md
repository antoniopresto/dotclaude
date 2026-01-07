# Plano de Correção: MMS V1.0 GENESIS Reset

## LIÇÃO CRÍTICA (SALVAR EM DISCO)

**ERRO COMETIDO**: Subagents sobrescreveram IMMUTABLE CONSTRAINTS do usuário.
**CAUSA RAIZ**: Agente confiou em análises de subagents sobre diretivas explícitas do usuário.
**PREVENÇÃO**: Orientações do usuário são IMUTÁVEIS. Subagents NÃO podem alterá-las.

### Regra a Adicionar ao CLAUDE.md
```markdown
## REGRA CRÍTICA: HIERARQUIA DE AUTORIDADE

1. **DIRETIVAS DO USUÁRIO** → IMUTÁVEIS, nunca sobrescrever
2. **IMMUTABLE CONSTRAINTS** → Definidas pelo usuário, não negociáveis
3. **Decisões de subagents** → Apenas dentro do escopo permitido

PROIBIDO: Subagents alterarem stack, design system, ou constraints definidos pelo usuário.

## REGRA CRÍTICA: AUTONOMIA COM CONSTRAINTS

NA DÚVIDA:
1. Consultar constraints em disco (progress.txt, features.json, commits)
2. Seguir a lógica definida nas constraints
3. Continuar até conclusão SEM PAUSAR
4. NÃO perguntar ao usuário - as constraints já definem o caminho

NUNCA:
- Confiar apenas na memória (contexto reseta)
- Pausar para perguntar quando a resposta está em disco
- Sobrescrever constraints com "decisões" de subagents
```

### Registro a Adicionar ao .harness/progress.txt
```markdown
## ERRO HISTÓRICO (2026-01-06) - NUNCA REPETIR

**O que aconteceu**: Phase 5 subagents decidiram "Keep BlueprintJS" quando
a constraint original dizia "BlueprintJS → PatternFly v6".

**Por que foi errado**: IMMUTABLE CONSTRAINTS são diretivas do usuário.
Subagents não têm autoridade para alterá-las.

**Como evitar**:
1. Ler constraints em disco ANTES de delegar a subagents
2. Constraints do usuário são IMUTÁVEIS - seguir sem questionar
3. Na dúvida, CONSULTAR commits/constraints - NÃO perguntar ao usuário
4. NUNCA confiar em memória - salvar tudo em disco
5. Continuar até conclusão SEM PAUSAR
```

---

## Análise do Erro

### Timeline do Problema
```
23/Dez/2025: 6505e9e "reset project" - Reset CORRETO (deletou apps/canvas)
28/Dez/2025: 1628367 "Revert reset" - Restaurou código velho (ERRO)
06/Jan/2026: 68e1ce2 "initialize genesis" - Iniciou genesis
06/Jan/2026: 653437a "decision debates" - Subagents SOBRESCREVERAM constraints
06/Jan/2026: 71fda92 "SPECIFICATION.md" - Spec escrita com decisões erradas
06/Jan/2026: adc97a9 "GENESIS complete" - apps/canvas mantido com código velho
06/Jan/2026: 15e7d6f "verify features" - Agente verificou código errado como "passing"
```

### Constraint Original (Violada)
```markdown
## IMMUTABLE CONSTRAINTS (V1.0)
| From | To |
|------|-----|
| BlueprintJS 6 | PatternFly v6 |  ← ESTA ERA A DIRETIVA
```

### Decisão Errada dos Subagents
```markdown
DECISION-002: PatternFly vs BlueprintJS
DECISION: Keep BlueprintJS 6 for V1.0. PatternFly migration is V1.1.
← ISTO VIOLOU A CONSTRAINT IMUTÁVEL
```

---

## Commits a Reverter

| Commit | Descrição | Ação |
|--------|-----------|------|
| 15e7d6f | verify 11 features | REVERTER |
| adc97a9 | GENESIS complete | REVERTER |
| 97da6f3 | Phase 6 complete | REVERTER |
| 71fda92 | SPECIFICATION.md | REVERTER |
| a8914dd | Phase 5 complete | REVERTER |
| 653437a | decision debates | REVERTER |

**Ponto de reset**: `bf1541a` (Phase 4 complete) - último commit correto

---

## Perguntas para o Usuário

Antes de executar, preciso confirmar:

1. **Reverter até bf1541a?** Isso descarta Phase 5-8 e recomeça a partir de Phase 4 complete.

2. **O design system PatternFly v6 é obrigatório?** A diretiva original dizia "BlueprintJS → PatternFly"

3. **O que fazer com apps/canvas?**
   - Opção A: Deletar completamente e reconstruir do zero com PatternFly
   - Opção B: Manter estrutura, migrar componentes para PatternFly
   - Opção C: Reset parcial (manter apenas lógica de canvas, reescrever UI)

4. **Há referências de design/mockups que devo seguir?** Ou devo pesquisar PatternFly v6 e criar do zero?

---

## Próximos Passos (Aguardando Confirmação)

### Fase 1: Reverter
```bash
git revert --no-commit 15e7d6f..HEAD
git commit -m "revert: undo erroneous Phase 5-8 commits"
```

### Fase 2: Recomeçar Phase 5
- Respeitar IMMUTABLE CONSTRAINTS
- PatternFly v6 é OBRIGATÓRIO
- NÃO delegar decisões de stack para subagents

### Fase 3: Reset apps/canvas
- Opção a ser definida pelo usuário

### Fase 4: Implementar com PatternFly v6
- Seguir design system correto
- Construir do zero se necessário

---

---

## DECISÕES CONFIRMADAS

1. **Reverter até bf1541a**: SIM - descartar Phase 5-8
2. **apps/canvas**: Deletar e reconstruir do zero com PatternFly v6
3. **Design system**: Pesquisar PatternFly v6, criar baseado nos padrões

---

## PLANO DE EXECUÇÃO (SEM PAUSAR)

### Passo 1: Registrar erro em disco
**Arquivos a editar:**
- `.harness/progress.txt` - Adicionar seção ERRO HISTÓRICO
- `CLAUDE.md` - Adicionar REGRAS CRÍTICAS de hierarquia e autonomia

### Passo 2: Reverter commits
```bash
git revert --no-commit 15e7d6f adc97a9 97da6f3 71fda92 a8914dd 653437a
git commit -m "revert: undo Phase 5-8 - subagents violaram IMMUTABLE CONSTRAINTS"
```

### Passo 3: Deletar apps/canvas
```bash
rm -rf apps/canvas/
git add -A
git commit -m "chore: delete apps/canvas for clean rebuild with PatternFly v6"
```

### Passo 4: Atualizar harness para Phase 5 restart
- Editar `.harness/progress.txt` - marcar Phase 5 como "RESTART"
- Editar `.harness/features.json` - resetar status de features

### Passo 5: Recomeçar Phase 5 respeitando constraints
- PatternFly v6 é OBRIGATÓRIO (constraint original)
- NÃO delegar decisão de stack para subagents
- Decisões dentro do escopo: performance, features secundárias

### Passo 6: Criar novo apps/canvas com PatternFly v6
- Pesquisar PatternFly v6 (WebSearch)
- Estrutura mínima: Vite + React 18 + PatternFly v6 + R3F
- Seguir mesma arquitetura de LOD (Macro/Meso/Micro)

---

## CONSTRAINTS ORIGINAIS (IMUTÁVEIS)

Extraídas de `genesis/MMS_V1_GENESIS.md`:

| From | To |
|------|-----|
| BlueprintJS 6 | **PatternFly v6** |
| @zazcart/toolkit | @belt/tools |
| packages/toolkit/ | DELETE (use npm) |

**MAGNA RULES:**
1. NO NEXT.JS - Vite + React
2. AVOID REACT HOOKS - Use state-machine
3. COMMIT FREQUENTLY

---

## Status
**PRONTO PARA EXECUTAR** - Aguardando sair do plan mode
