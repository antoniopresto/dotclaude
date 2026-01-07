# Plano: Integrar Elementos do Harness ao Projeto MFC (BMAD)

## Resumo

Adicionar elementos do Anthropic Harness Method que **complementam** o BMAD v6, focando em continuidade entre sessões e protocolos que o BMAD não oferece nativamente.

---

## Análise: O que cada metodologia oferece

### BMAD v6 JÁ TEM (não duplicar):
- **Testes**: testarch completo com Playwright config (730+ linhas)
- **CI/CD**: Templates GitHub Actions + GitLab CI em `_bmad/bmm/workflows/testarch/ci/`
- **Agente TEA**: Test Engineer/Architect especializado
- **Workflows**: ATDD, automate, framework, test-design, test-review, trace, nfr-assess
- **32+ knowledge files** sobre testing patterns

### HARNESS TEM (adicionar ao MFC):
1. **Continuidade entre sessões**: `claude-progress.txt` + `features.json`
2. **Session hooks**: Injeção de contexto no início/fim de sessão
3. **Self-correction protocol**: Melhoria contínua da documentação
4. **CLAUDE.md**: Regras específicas do projeto (o MFC não tem)
5. **QA Protocol doc**: Checklist visual obrigatório

---

## Itens de Melhoria

### 1. Criar Arquivos de Continuidade Harness
**Arquivos a criar:**

```
/Users/anotonio.silva/antonio/mms/MFC/
├── claude-progress.txt      # Histórico de sessões e decisões
├── features.json            # Tracking de features (passes: true/false)
└── CLAUDE.md                # Regras do projeto para o agente
```

**claude-progress.txt** - Template:
```
# MMS-MFC Progress Log
# Format: [DATE] SESSION-ID: Summary

## Current State
- Phase: Planning (BMAD Phase 1-2)
- Next action: Execute workflow-init
- Blockers: None

## Session History
[2025-01-XX] SESSION-001: Initial setup
```

**features.json** - Template:
```json
{
  "version": "1.0.0",
  "features": [
    { "id": "SETUP-001", "name": "Project scaffolding", "passes": false },
    { "id": "TEST-001", "name": "Playwright framework setup", "passes": false },
    { "id": "API-001", "name": "Core API endpoints", "passes": false }
  ]
}
```

---

### 2. Melhorar Hooks (.claude/hooks)
**Arquivos a criar/modificar:**

| Arquivo | Propósito | Baseado em |
|---------|-----------|------------|
| `session-start.sh` | Injetar contexto harness + BMAD | system/.claude/hooks |
| `end-of-turn-check.sh` | Verificar estado limpo | system/.claude/hooks |

**session-start.sh** - Deve incluir:
- Data atual (evitar dados de treino desatualizados)
- Lembrete para ler `claude-progress.txt`
- Status do workflow BMAD atual
- Lembrete de testes visuais obrigatórios

---

### 3. Criar CLAUDE.md (Regras do Projeto)
**Caminho:** `/Users/anotonio.silva/antonio/mms/MFC/CLAUDE.md`

**Conteúdo essencial:**
```markdown
# MMS-MFC Project Rules

## Critical Rules
1. CHECK CURRENT DATE - Training data may be stale
2. YOU CANNOT SEE UI - Use Playwright MCP for visual verification
3. READ claude-progress.txt FIRST - Understand session context
4. FOLLOW BMAD WORKFLOWS - Use `*workflow-init`, `*dev-story`, etc.

## State Management
- Use @zazcart/toolkit (already installed)
- Avoid React hooks for app state

## Testing Protocol
- All UI changes require Playwright screenshot verification
- Run *testarch-framework before first test
```

---

### 4. Executar Workflow BMAD para Testes
**Comando:** `*testarch-framework`

Este workflow BMAD já configura:
- playwright.config.ts com best practices
- Estrutura de fixtures
- Integração CI/CD
- Reporters (HTML, JUnit)

**Não precisa recriar** - apenas executar o workflow existente.

---

### 5. Atualizar .claude/settings.json
**Adicionar hooks:**
```json
{
  "hooks": {
    "session_start": [
      { "type": "command", "command": ".claude/hooks/session-start.sh" }
    ],
    "pre_tool_use": [
      { "type": "command", "command": ".claude/hooks/protect-package.json.sh" }
    ]
  }
}
```

---

## Arquivos Críticos a Modificar

| Arquivo | Ação |
|---------|------|
| `CLAUDE.md` | Criar (novo) |
| `claude-progress.txt` | Criar (novo) |
| `features.json` | Criar (novo) |
| `.claude/hooks/session-start.sh` | Criar (novo) |
| `.claude/hooks/end-of-turn-check.sh` | Criar (novo) |
| `.claude/settings.json` | Modificar (adicionar hooks) |

---

## Ordem de Execução

1. **Criar CLAUDE.md** com regras do projeto
2. **Criar claude-progress.txt** com estado inicial
3. **Criar features.json** com features planejadas do MMS_DEMO_PLAYBOOK
4. **Criar hooks** (session-start.sh, end-of-turn-check.sh)
5. **Atualizar .claude/settings.json** para registrar hooks
6. **Executar `*testarch-framework`** (workflow BMAD) para setup de testes
7. **Validar** que Playwright MCP funciona corretamente

---

## O que NÃO fazer

- ❌ Duplicar configuração de testes (BMAD já tem)
- ❌ Criar CI/CD templates (BMAD já tem em `_bmad/bmm/workflows/testarch/ci/`)
- ❌ Substituir BMAD por Harness (são complementares)
- ❌ Copiar @mms/toolkit (já está instalado como `@zazcart/toolkit`)

---

## Resultado Esperado

Após implementação:
- Agente terá contexto de sessões anteriores (continuidade Harness)
- Testes visuais obrigatórios (protocolo Harness + infra BMAD)
- Workflows BMAD funcionando com state tracking
- Hooks garantindo qualidade a cada sessão
