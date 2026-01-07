# Análise: Por que o BMAD v6 não está sendo usado corretamente

## Resumo do Problema

O Claude Code **ignora** os workflows BMAD e vai direto para implementação, mesmo com:
- BMAD v6 instalado (v6.0.0-alpha.21)
- 65 comandos registrados em `.claude/commands/bmad/`
- Hooks de enforcement configurados

---

## Descobertas da Análise

### 1. O Hook de Enforcement NÃO BLOQUEIA

**Arquivo**: `.claude/hooks/bmad-enforcement.sh`

**Problema**: O script **sempre retorna `exit 0`**:
```bash
# Linha 73-74
fi
exit 0  # <-- SEMPRE PERMITE, NUNCA BLOQUEIA!
```

**Efeito**: O hook apenas EXIBE uma mensagem de aviso, mas o Claude pode (e vai) ignorá-la.

**Solução**: Retornar `exit 1` para BLOQUEAR requisições de implementação sem workflow.

---

### 2. O Claude Não Está Usando a Ferramenta Skill

**Problema**: Quando o usuário pede "fix this bug" ou "add this feature", o Claude deveria:
1. Detectar que é implementação
2. Usar a ferramenta `Skill` para invocar `*dev-story` ou `*correct-course`

**O que acontece**: Claude ignora os workflows e implementa diretamente.

**Evidência do system prompt**:
```
Available skills:
- bmad:bmm:workflows:dev-story
- bmad:bmm:workflows:correct-course
- bmad:bmm:workflows:code-review
...
```

As skills ESTÃO disponíveis, mas o Claude não está sendo instruído a usá-las.

---

### 3. CLAUDE.md Não É Enfático o Suficiente

**Problema**: O CLAUDE.md menciona BMAD mas não FORÇA seu uso:
```markdown
# CRITICAL AI RULES
...
### Rule 5: FOLLOW BMAD WORKFLOWS
Don't freestyle implementation. Use BMAD agents and workflows...
```

**Isso é insuficiente** porque:
- Está no final do documento (baixa prioridade)
- Não especifica QUANDO usar cada workflow
- Não diz que é OBRIGATÓRIO

---

### 4. O Workflow Engine É Colaborativo (E Isso Não Está Claro)

**De `_bmad/core/tasks/workflow.xml`**:
```xml
<critical-rules>
  YOU ARE FACILITATING A CONVERSATION with a user to produce
  a final document step by step. The whole process is meant to
  be collaborative helping the user flesh out their ideas.
</critical-rules>
```

**Implicação**: Os workflows BMAD são INTERATIVOS - o Claude deveria parar em cada seção e conversar com o usuário. Mas sem invocar o workflow, nada disso acontece.

---

### 5. IDE Config Incompleta

**Arquivo**: `_bmad/_config/ides/claude-code.yaml`
```yaml
configuration:
  subagentChoices: null     # <-- Não configurado
  installLocation: null      # <-- Não configurado
```

Isso sugere que o instalador BMAD não completou a configuração do Claude Code.

---

## Problemas Identificados (Resumo)

| # | Problema | Severidade | Causa Raiz |
|---|----------|------------|------------|
| 1 | Hook não bloqueia | CRÍTICO | `exit 0` sempre |
| 2 | Skill tool não invocado | CRÍTICO | CLAUDE.md não força |
| 3 | Instruções fracas | ALTO | Regras no final do doc |
| 4 | IDE config incompleta | MÉDIO | Instalação parcial |
| 5 | Falta trigger automático | ALTO | Sem detecção de contexto |

---

## Plano de Correção

### Correção 1: Tornar Hook BLOQUEANTE (CRÍTICO)

**Arquivo**: `.claude/hooks/bmad-enforcement.sh`

```bash
# ANTES (linha ~74)
exit 0

# DEPOIS
# Se mostrou mensagem de enforcement, BLOQUEAR
if [ -n "$SHOWED_ENFORCEMENT" ]; then
    exit 1  # BLOQUEIA a requisição
fi
exit 0
```

### Correção 2: Mover Regras BMAD para o TOPO do CLAUDE.md

O modelo dá mais peso a instruções no INÍCIO do documento. Mover a seção de workflows BMAD para logo após o "Project Overview".

### Correção 3: Adicionar Trigger Automático no CLAUDE.md

```markdown
## MANDATORY WORKFLOW TRIGGERS

BEFORE ANY implementation, you MUST invoke the appropriate Skill:

| User Request | Required Skill |
|--------------|----------------|
| "fix bug", "resolve error" | `Skill: bmad:bmm:workflows:dev-story` |
| "add feature", "implement" | `Skill: bmad:bmm:workflows:create-story` → `dev-story` |
| "refactor", "optimize" | `Skill: bmad:bmm:workflows:correct-course` |
| "review code" | `Skill: bmad:bmm:workflows:code-review` |

NEVER implement directly. ALWAYS use the Skill tool first.
```

### Correção 4: Adicionar Verificação Pós-Implementação

Criar um hook `PostToolUse` que verifica se edições foram feitas sem um workflow ativo:

```bash
# .claude/hooks/verify-workflow-active.sh
if [ "$TOOL_NAME" = "Edit" ] || [ "$TOOL_NAME" = "Write" ]; then
    # Check if we're in a BMAD workflow context
    # If not, warn
fi
```

### Correção 5: Reinstalar BMAD Corretamente

```bash
npx bmad-method install
```

E verificar se a configuração do IDE está completa.

---

## Arquivos a Modificar

1. `.claude/hooks/bmad-enforcement.sh` - Tornar bloqueante
2. `CLAUDE.md` - Reorganizar e fortalecer regras
3. `.claude/settings.json` - Adicionar hook PostToolUse (opcional)
4. `_bmad/_config/ides/claude-code.yaml` - Verificar config

---

## Validação

Após correções, testar com:
1. Pedir "fix the bug in X" - deve invocar `*dev-story`
2. Pedir "add feature Y" - deve invocar `*create-story` primeiro
3. Tentar implementar diretamente - deve ser BLOQUEADO

---

---

## NOVO: Problema de Descoberta de Comandos (Bug do Claude Code)

### O Problema

O usuário identificou um **bug crítico** no Claude Code:
> Comandos em pastas profundas NÃO são descobertos pelo autocompletar/slash commands.

**Estrutura atual (problemática)**:
```
.claude/commands/
└── bmad/              # <-- Só pasta, sem arquivos .md na raiz
    ├── core/
    │   └── agents/
    │       └── bmad-master.md    # <-- 4 níveis de profundidade!
    ├── bmb/
    └── bmm/
        └── workflows/
            └── dev-story.md      # <-- 5 níveis de profundidade!
```

**Total de comandos em subpastas**: 57 arquivos .md
**Comandos na raiz**: 0

### Solução: Criar Aliases na Raiz

Criar arquivos "proxy" na raiz que apontem para os arquivos reais:

**Exemplo de alias** (`.claude/commands/dev-story.md`):
```markdown
---
description: 'Execute story implementation (alias for bmad:bmm:workflows:dev-story)'
---

@include .claude/commands/bmad/bmm/workflows/dev-story.md
```

**OU** usar symlinks:
```bash
cd .claude/commands
ln -s bmad/bmm/workflows/dev-story.md dev-story.md
ln -s bmad/bmm/workflows/code-review.md code-review.md
# ... etc
```

### Aliases Prioritários a Criar

| Alias na Raiz | Aponta Para | Uso |
|--------------|-------------|-----|
| `dev-story.md` | `bmad/bmm/workflows/dev-story.md` | Implementar stories |
| `code-review.md` | `bmad/bmm/workflows/code-review.md` | Revisar código |
| `correct-course.md` | `bmad/bmm/workflows/correct-course.md` | Bug fixes/correções |
| `sprint-status.md` | `bmad/bmm/workflows/sprint-status.md` | Ver status do sprint |
| `create-story.md` | `bmad/bmm/workflows/create-story.md` | Criar nova story |
| `create-tech-spec.md` | `bmad/bmm/workflows/create-tech-spec.md` | Tech specs |
| `quick-dev.md` | `bmad/bmm/workflows/quick-dev.md` | Dev rápido |
| `retrospective.md` | `bmad/bmm/workflows/retrospective.md` | Retrospectivas |

---

## Plano de Correção ATUALIZADO

### Fase 1: Investigação Completa (CONCLUÍDA)

- [x] Analisar estrutura atual do BMAD
- [x] Verificar hooks de enforcement
- [x] Identificar problema de descoberta de comandos
- [x] Consultar documentação oficial

### Fase 2: Correções a Implementar

#### 2.1 Criar Aliases na Raiz (PRIORITÁRIO)

```bash
# Opção A: Symlinks (mais simples)
cd .claude/commands
for cmd in dev-story code-review correct-course sprint-status create-story quick-dev retrospective; do
    ln -sf bmad/bmm/workflows/${cmd}.md ${cmd}.md
done

# Opção B: Arquivos proxy (mais explícito)
# Criar cada arquivo com @include
```

#### 2.2 Tornar Hook Bloqueante

**Arquivo**: `.claude/hooks/bmad-enforcement.sh`

```bash
# Adicionar antes do exit 0 final
if [ "$ENFORCEMENT_TRIGGERED" = "true" ]; then
    echo "⛔ BLOQUEADO: Use um workflow BMAD primeiro (*dev-story, *correct-course, etc.)"
    exit 1
fi
```

#### 2.3 Fortalecer CLAUDE.md

Mover regras BMAD para o TOPO e adicionar:

```markdown
## ⚠️ WORKFLOW OBRIGATÓRIO (NUNCA IGNORE)

ANTES de qualquer implementação, você DEVE:
1. Rodar `/sprint-status` para ver o estado atual
2. Usar o workflow apropriado:
   - `/dev-story` para implementar stories existentes
   - `/correct-course` para bug fixes e ajustes
   - `/create-story` para novas features
   - `/code-review` após implementação

NUNCA faça implementação direta. SEMPRE use um workflow.
```

#### 2.4 Verificar Configuração do IDE

```bash
npx bmad-method doctor  # Se existir
# Ou verificar manualmente _bmad/_config/ides/claude-code.yaml
```

### Fase 3: Validação

1. Testar que `/dev-story` é descoberto no autocompletar
2. Testar que hook bloqueia implementação direta
3. Testar que workflow é executado corretamente

---

## Arquivos a Modificar

| Arquivo | Ação |
|---------|------|
| `.claude/commands/dev-story.md` | CRIAR (alias) |
| `.claude/commands/code-review.md` | CRIAR (alias) |
| `.claude/commands/correct-course.md` | CRIAR (alias) |
| `.claude/commands/sprint-status.md` | CRIAR (alias) |
| `.claude/commands/create-story.md` | CRIAR (alias) |
| `.claude/commands/quick-dev.md` | CRIAR (alias) |
| `.claude/commands/retrospective.md` | CRIAR (alias) |
| `.claude/hooks/bmad-enforcement.sh` | MODIFICAR (bloqueante) |
| `CLAUDE.md` | MODIFICAR (fortalecer regras) |

---

## Próximos Passos

Com base nas suas respostas:
1. **Enforcement Bloqueante**: Sim - modificar hook para `exit 1`
2. **Investigar primeiro**: Concluído - problema identificado

**Pronto para implementar.** Decisões confirmadas:

| Decisão | Escolha |
|---------|---------|
| Enforcement | Bloqueante (exit 1) |
| Tipo de Alias | Symlinks |

## Sequência de Implementação

```bash
# 1. Criar symlinks para workflows principais
cd /Users/anotonio.silva/antonio/mms/MFC/.claude/commands
ln -sf bmad/bmm/workflows/dev-story.md dev-story.md
ln -sf bmad/bmm/workflows/code-review.md code-review.md
ln -sf bmad/bmm/workflows/correct-course.md correct-course.md
ln -sf bmad/bmm/workflows/sprint-status.md sprint-status.md
ln -sf bmad/bmm/workflows/create-story.md create-story.md
ln -sf bmad/bmm/workflows/quick-dev.md quick-dev.md
ln -sf bmad/bmm/workflows/retrospective.md retrospective.md
ln -sf bmad/bmm/workflows/workflow-status.md workflow-status.md

# 2. Criar symlinks para agentes principais
ln -sf bmad/bmm/agents/dev.md dev.md
ln -sf bmad/bmm/agents/architect.md architect.md
ln -sf bmad/bmm/agents/pm.md pm.md

# 3. Modificar bmad-enforcement.sh para ser bloqueante
# (editar arquivo conforme descrito acima)

# 4. Reorganizar CLAUDE.md
# (mover seção BMAD para o topo)
```

## Resultado Esperado

Após implementação:
- `/dev-story` aparece no autocompletar ✓
- `/code-review` aparece no autocompletar ✓
- Implementação direta é BLOQUEADA ✓
- Workflows são executados corretamente ✓
