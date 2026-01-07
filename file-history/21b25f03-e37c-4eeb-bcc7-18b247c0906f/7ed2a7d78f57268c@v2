# Plano: Recriar Harness V1.0 Corretamente

## Documento Mestre Recebido

O usuário forneceu o **MMS V1.0 GENESIS — Master Orchestration Architecture** completo.

Este documento define:
- Role: Lead System Architect & Knowledge Orchestrator
- 5 Core Heuristics (Trust Nothing, Parallel Wide, Disk Over Memory, One Feature One Session, Decisions Through Debate)
- 8 Execution Phases
- Immutable Constraints (PatternFly v6, @belt/tools, etc.)
- Preserved Knowledge (technical patterns, domain, competitors)

## Ação Imediata

Conforme instruído: **"Do not ask for confirmation. Do not ask questions. Execute."**

### 1. Limpar .harness/

```bash
# Mover TUDO para archive
mkdir -p .harness/archive/pre-v1
mv .harness/*.txt .harness/archive/pre-v1/
mv .harness/*.json .harness/archive/pre-v1/
mv .harness/*.md .harness/archive/pre-v1/
mv .harness/BACKUP_PROJECT_HARNESS .harness/archive/pre-v1/
```

### 2. Criar novo harness

- `.harness/ORCHESTRATION.md` - O documento mestre fornecido pelo usuário
- `.harness/features.json` - Novo, com fases de migração
- `.harness/progress.txt` - Novo, limpo

### 3. Atualizar CLAUDE.md

Reescrever para V1.0:
- Remover BlueprintJS → PatternFly v6
- Remover @zazcart/tools → @belt/tools
- Remover seções obsoletas (Parallel Execution, POC, etc.)
- Apontar para novo harness

### 4. Criar _migration_memory/

```bash
mkdir -p _migration_memory
```

### 5. Iniciar Fase 1: Territory Mapping

Seguir o documento mestre - lançar agente para mapear território.

## Arquivos a Modificar

1. `.harness/` - Limpar e recriar
2. `CLAUDE.md` - Reescrever para V1.0
3. `_migration_memory/` - Criar diretório

## Instrução Final

Sair do plan mode e executar imediatamente.
