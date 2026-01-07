# MMS V1.0 GENESIS - Plano de Execução

## Princípio Fundamental

**HARNESS FIRST**: Nada é executado sem antes estar registrado no harness.
- Cada tarefa deve existir em `features.json` ANTES de ser implementada
- Cada progresso deve ser registrado em `progress.txt` IMEDIATAMENTE após conclusão
- Commits atômicos a cada pequeno progresso
- Em caso de erro/estouro de contexto: recuperação total via harness

---

## FASE 0: Reset do Harness (PRIMEIRO)

### 0.1 Verificar backup existente
- [x] Backup já existe em `.harness/archive/pre-v1/`
- Confirmar que todos os arquivos antigos estão preservados

### 0.2 Criar novo harness V1.0
**Arquivos a criar:**
- `.harness/progress.txt` - Log de sessões (novo, vazio)
- `.harness/features.json` - Features de genesis (novo)

### 0.3 Atualizar CLAUDE.md
Adicionar seção enfatizando:
- HARNESS FIRST: Registrar antes de executar
- Commits atômicos a cada progresso
- Recuperação via progress.txt

---

## FASE 1: Features de Genesis (a registrar no harness)

### Extraction Phase (E001-E012) - JÁ COMPLETO
Os 12 arquivos em `_migration_memory/` representam trabalho já feito:
- `00_TERRITORY_MAP.md` - Mapeamento dos 6 repos
- `01_canvas.md` até `12_canvas_tech.md` - Extração de conhecimento

### Validation Phase (V001-V004)
- V001: Validar formulas matemáticas
- V002: Validar terminologia de domínio
- V003: Validar claims técnicos
- V004: Validar claims de performance

### Decision Phase (D001-D004)
- D001: Decisão de tecnologia canvas (R3F vs alternativas)
- D002: Decisão de estrutura da spec
- D003: Decisão de escopo V1.0
- D004: Decisão de integração PatternFly

### Specification Phase (S001-S004)
- S001: Escrever Part I - Domain
- S002: Escrever Part II - Architecture
- S003: Escrever Part III - UX
- S004: Editar e consolidar

### Cleanup Phase (C001-C005)
- C001: Deletar packages/ deprecated
- C002: Atualizar dependencies
- C003: Limpar docs/ antigos
- C004: Deletar _migration_memory/
- C005: Commit baseline V1.0

### Implementation Phase (F001-F020)
- F001: Vite + React 18 + PatternFly v6 scaffold
- F002: Storybook 8 setup
- F003: @belt/tools integration
- F004-F010: Canvas Foundation
- F011-F015: UI Integration
- F016-F020: Solver Integration

---

## Arquivos Críticos a Modificar

1. **`.harness/features.json`** (CRIAR)
   - Estrutura JSON com todas as features acima
   - Cada feature com: id, category, description, verification, passes

2. **`.harness/progress.txt`** (CRIAR)
   - Header com data e sessão
   - Log de cada ação tomada
   - Estado de recuperação

3. **`CLAUDE.md`** (ATUALIZAR)
   - Adicionar seção "HARNESS FIRST Protocol"
   - Enfatizar commits atômicos
   - Documentar recuperação

---

## Ordem de Execução

```
1. Verificar backup (.harness/archive/pre-v1/) ✓
2. Criar .harness/features.json com todas as features
3. Criar .harness/progress.txt inicial
4. Atualizar CLAUDE.md com HARNESS FIRST
5. COMMIT: "chore: reset harness for V1.0 genesis"
6. Executar features uma a uma (harness protocol)
```

---

## Recuperação de Contexto

Em caso de estouro de contexto ou erro:
```bash
# 1. Ler estado atual
cat .harness/progress.txt | tail -50
cat .harness/features.json | jq '.features[] | select(.passes==false) | .id' | head -1

# 2. Verificar último commit
git log --oneline -5

# 3. Continuar da próxima feature pendente
```

---

## Próximo Passo Imediato

**AÇÃO**: Criar `.harness/features.json` e `.harness/progress.txt` com as tarefas de genesis, depois commit.
