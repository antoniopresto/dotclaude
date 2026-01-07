# Plano: Configurar Harness para Feature SPMAIS-31425

## Objetivo Principal
Configurar o Harness do projeto para entregar a feature SPMAIS-31425 (Resgate Cashback Fatura) de forma automatizada e segura, com rastreamento de progresso entre sessões.

---

## Contexto da Feature (de .wip/)

**Task:** SPMAIS-31425 - Resgate Cashback na Fatura
- Exibir tela de Onboarding apenas para clientes que **nunca** resgataram cashback
- Se já resgatou, pular direto para tela de seleção de valores
- Após primeiro resgate bem-sucedido, marcar no backend

**Implementação atual (commit f98192c3):**
- Service layer criado: `src/services/invoiceCashbackPermission/`
- Hook de navegação modificado: `src/hooks/custom/useCardBuilderWhereUseMyPoints/`
- Tela de resumo modificada: `src/screens/InvoiceCashbackSummary/`

**Bug atual:** Chamada à API não está sendo feita (investigação pendente)

---

## Arquivos do Harness a Modificar

| Arquivo | Ação |
|---------|------|
| `features.json` | Substituir conteúdo com features da task SPMAIS-31425 |
| `claude-progress.txt` | Atualizar com contexto completo da sessão |

---

## Plano de Implementação

### Passo 1: Atualizar features.json

Substituir o conteúdo atual por:

```json
{
  "project": "rnm-app-fintech-card-place",
  "version": "0.2.0",
  "description": "Feature SPMAIS-31425: Invoice Cashback Permission Check",
  "lastUpdated": "2025-12-17",
  "task": {
    "jira": "SPMAIS-31425",
    "title": "Resgate Cashback na Fatura - Verificação de Permissão",
    "branch": "feature/SPMAIS-31425-resgate-cashback-fatura"
  },
  "features": [
    {
      "id": "F001",
      "category": "setup",
      "description": "Harness configurado com contexto da task",
      "passes": true,
      "blockedBy": null,
      "notes": "Configuração inicial do harness"
    },
    {
      "id": "F002",
      "category": "investigation",
      "description": "Investigar e corrigir bug: chamada API não está sendo feita",
      "steps": [
        "Verificar se accountId está disponível no momento da chamada",
        "Verificar se throw Error está impedindo a execução",
        "Corrigir tratamento de accountId undefined",
        "Testar que a chamada é feita corretamente"
      ],
      "passes": false,
      "blockedBy": null,
      "notes": "Bug identificado: chamada à API não acontece"
    },
    {
      "id": "F003",
      "category": "cleanup",
      "description": "Remover console.logs de debug da implementação",
      "steps": [
        "Remover logs de useCardBuilderWhereUseMyPoints",
        "Remover logs de invoiceCashbackPermission service"
      ],
      "passes": false,
      "blockedBy": "F002",
      "notes": "Limpeza antes do merge"
    },
    {
      "id": "F004",
      "category": "test",
      "description": "Executar testes e verificar implementação",
      "steps": [
        "Rodar testes unitários existentes",
        "Verificar que todos passam"
      ],
      "passes": false,
      "blockedBy": "F003"
    },
    {
      "id": "F005",
      "category": "delivery",
      "description": "Commit final e preparação para merge",
      "steps": [
        "Commit das correções",
        "Atualizar claude-progress.txt",
        "Preparar PR se solicitado"
      ],
      "passes": false,
      "blockedBy": "F004"
    }
  ]
}
```

### Passo 2: Atualizar claude-progress.txt

Substituir o conteúdo com:

```markdown
# rnm-app-fintech-card-place - Progress Log

## Project Goal
Implementar feature SPMAIS-31425: Verificação de permissão de cashback na fatura
- Pular onboarding para clientes que já resgataram
- Marcar permissão após primeiro resgate bem-sucedido

---

## Session 1 - 2025-12-17 - Initial Harness Setup

### Context
Harness inicial criado.

### Completed ✅
- Harness structure created

### Current State
| Feature | Status | Notes |
|---------|--------|-------|
| F001 | ✅ Done | Setup |

---

## Session 2 - 2025-12-17 - Feature Implementation (commit f98192c3)

### Context
Implementação da feature SPMAIS-31425 realizada.

### Completed ✅
- Service layer: `src/services/invoiceCashbackPermission/` (api, repository, services, store, hooks)
- Navegação condicional em `useCardBuilderWhereUseMyPoints`
- Marcação pós-resgate em `InvoiceCashbackSummary`
- Testes unitários criados

### Issues Found 🐛
- Bug: chamada à API não está sendo feita
- Staging area tem mudanças de debug (console.logs)

### Current State
| Feature | Status | Notes |
|---------|--------|-------|
| F001 | ✅ Done | Setup |
| F002 | 🔄 In Progress | Bug investigation needed |
| F003 | ○ Pending | Cleanup blocked by F002 |
| F004 | ○ Pending | Tests blocked by F003 |
| F005 | ○ Pending | Delivery blocked by F004 |

### Next Session Priorities
1. Investigar e corrigir bug da API
2. Remover console.logs de debug
3. Rodar testes
4. Commit final

---

## Key Files Reference

### Service Layer
- `src/services/invoiceCashbackPermission/api/index.ts` - HTTP client
- `src/services/invoiceCashbackPermission/repository/index.ts` - Data layer
- `src/services/invoiceCashbackPermission/services/index.ts` - Business logic
- `src/services/invoiceCashbackPermission/store/index.ts` - Zustand slice
- `src/services/invoiceCashbackPermission/hooks/useInvoiceCashbackPermission.ts` - React hook

### Integration Points
- `src/hooks/custom/useCardBuilderWhereUseMyPoints/index.ts` - Navigation decision
- `src/screens/InvoiceCashbackSummary/index.tsx` - Post-rescue marking

### Tests
- `__tests__/services/invoiceCashbackPermission/hooks/useInvoiceCashbackPermission.test.ts`
- `__tests__/services/invoiceCashbackPermission/services/index.test.ts`

---

## Quick Start for New Session

\`\`\`bash
# 1. Read current state
cat claude-progress.txt
cat features.json | jq '.features[] | select(.passes == false) | .id + ": " + .description'

# 2. Work on next feature (F002)
# ... investigate and fix bug ...

# 3. Mark complete and commit
# Update features.json: passes: true
git add . && git commit -m "fix(SPMAIS-31425): fix API call issue"

# 4. Update this progress file
\`\`\`
```

### Passo 3: Após Harness Configurado

Com o harness configurado, a próxima feature a trabalhar será **F002** (investigar e corrigir o bug).

**Hipótese do bug:** No hook `useInvoiceCashbackPermission.ts:20-22`, há um `throw Error` quando `accountId` é undefined. Como o accountId vem do Redux e pode não estar disponível no momento do `useEffect` de preload, isso pode estar causando falha.

---

## Checklist de Execução

- [ ] **Passo 1:** Atualizar `features.json` com estrutura completa
- [ ] **Passo 2:** Atualizar `claude-progress.txt` com contexto
- [ ] **Passo 3:** Verificar harness status
- [ ] **Passo 4:** Iniciar trabalho em F002 (bug fix)

---

## Arquivos Críticos para F002 (Bug Fix)

**Arquivo:** `src/services/invoiceCashbackPermission/hooks/useInvoiceCashbackPermission.ts`

**Mudança:** Linha 20-22, reverter de:
```ts
if (!accountId) {
  throw new Error('Expected accountId to be defined.');
}
```

Para (comportamento original):
```ts
if (!accountId) {
  return false;
}
```

**Justificativa:** O comportamento original retornava `false` silenciosamente. Isso é correto porque:
1. O preload no `useEffect` usa `.catch(() => {})` - erros são ignorados
2. Quando o usuário clica no card, o accountId já estará disponível
3. O throw causa falha prematura antes do Redux estar hidratado

### Fase 3: Cleanup (F003)

**Remover os seguintes console.logs:**

1. `useCardBuilderWhereUseMyPoints/index.ts`:
   - Linha 18-19: `console.log('ESTAMERDA RETORNOU', res)`
   - Linha 21: `console.error('EXTAMERDA DEU ERRO', reason)`
   - Linha 67: `console.log('LIXO')`
   - Linha 87: `console.log('BUSCANDO ESTA BOSTA')`
   - Linha 89: `console.log('ESTA BOSTA RETORNOU', hasRedeemed)`

2. `invoiceCashbackPermission/services/index.ts`:
   - Linha 9: `console.log(result)`

### Fase 4: Testes (F004)

Executar:
```bash
npm test -- --testPathPattern="invoiceCashbackPermission"
```

### Fase 5: Commit (F005)

Após todas as features passarem, fazer commit com mensagem adequada.

---

## Checklist Final

- [ ] F002: Bug corrigido (return false ao invés de throw)
- [ ] F003: Console.logs removidos
- [ ] F004: Testes passando
- [ ] F005: Código commitado
- [ ] Harness atualizado (features.json e claude-progress.txt)
