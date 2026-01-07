# PLANO: Recomeçar MMS CORRETAMENTE

## ERRO CRÍTICO DESTA SESSÃO

1. **NÃO REGISTREI NADA EM DISCO** - Contexto acabando, nada salvo
2. **IGNOREI RESTRIÇÕES DO CLAUDE.md** - Propus usar BlueprintJS quando deve ser PatternFly 6
3. **CRIEI LIXO** - `_memory/extracted-knowledge.md` é inútil
4. **NÃO USEI SUBAGENTS** - Para web research e validação

## RESTRIÇÕES OBRIGATÓRIAS (do CLAUDE.md)

| USAR | NÃO USAR |
|------|----------|
| PatternFly 6 | BlueprintJS |
| @belt/tools | zustand/redux/xstate |
| React 19 | React 18 |
| Vite | Next.js |
| R3F 9 + Drei 10 | deck.gl (a avaliar) |

## DOCUMENTOS EXISTENTES = FONTE PARA BRAINSTORMING

**NÃO são SSOT** - Devem ser REVISADOS com:
- Web research (validar APIs, versões)
- Restrições do CLAUDE.md
- Design system do PatternFly 6 (NÃO cores customizadas)

Documentos úteis em `~/antonio/mms/deck/docs/`:
- RFQ.md - O que o cliente pediu (VÁLIDO)
- REQUIREMENTS.md - Requisitos mapeados (VÁLIDO)
- UX_SPECIFICATION.md - Semantic zoom, LOD (CONCEITOS válidos, stack errado)
- DESIGN_SPEC.md - Componentes (CONCEITOS válidos, usa BlueprintJS - SUBSTITUIR por PatternFly)

## AÇÃO IMEDIATA (ao sair do plan mode)

### 1. SALVAR APRENDIZADOS EM DISCO (progress.txt)

```
=== SESSION: 2026-01-06T15:30:00Z ===
ERRO CRÍTICO: TASK-050 criou documento inútil

APRENDIZADOS:
1. Docs existentes em ~/antonio/mms/deck/docs/ são FONTE para brainstorming, NÃO SSOT
2. DESIGN_SPEC.md usa BlueprintJS - DEVE ser adaptado para PatternFly 6
3. Conceitos válidos: Semantic Zoom, LOD (MACRO/MESO/MICRO), Sandbox Mode
4. Stack errado nos docs: React 18 + BlueprintJS → CORRIGIR para React 19 + PatternFly 6
5. NÃO criar cores customizadas - usar design system do PatternFly

PRÓXIMOS PASSOS:
1. Deletar _memory/extracted-knowledge.md (lixo)
2. Usar subagent para: pesquisar PatternFly 6 design system
3. Usar subagent para: criar SPEC adaptada (PatternFly + conceitos do DESIGN_SPEC)
4. Criar features.json com tarefas de implementação real
```

### 2. RESETAR features.json

Remover todas as tasks de "extração de conhecimento" e criar tasks de IMPLEMENTAÇÃO:

```json
{
  "tasks": [
    {
      "id": "SPEC-001",
      "description": "Criar especificação adaptada (PatternFly 6 + conceitos existentes)",
      "type": "subagent",
      "passes": false
    },
    {
      "id": "SETUP-001",
      "description": "Setup projeto: Vite + React 19 + PatternFly 6 + R3F 9",
      "passes": false
    },
    {
      "id": "IMPL-001",
      "description": "Phase 1: Wireframes com PatternFly",
      "passes": false
    }
  ]
}
```

### 3. USAR SUBAGENTS PARA

1. **Web research**: PatternFly 6 design system, componentes disponíveis
2. **Adaptação**: Pegar conceitos do DESIGN_SPEC e adaptar para PatternFly
3. **Implementação**: Cada task = um subagent

## CONCEITOS VÁLIDOS DOS DOCS EXISTENTES

| Conceito | Fonte | Status |
|----------|-------|--------|
| Semantic Zoom (Google Earth for time) | UX_SPECIFICATION.md | VÁLIDO |
| 3 LOD levels: MACRO/MESO/MICRO | UX_SPECIFICATION.md | VÁLIDO |
| Sandbox Mode (what-if) | DESIGN_SPEC.md | VÁLIDO - feature principal |
| Islands UI layout | DESIGN_SPEC.md | VÁLIDO - adaptar para PatternFly |
| RFQ requirements mapping | REQUIREMENTS.md | VÁLIDO |
| Design tokens/cores | DESIGN_SPEC.md | INVÁLIDO - usar PatternFly |

## STACK CORRETO (CLAUDE.md)

```
React 19 + PatternFly 6 + @belt/tools + R3F 9 + Drei 10 + Vite 6
```

**NÃO USAR:** BlueprintJS, zustand, xstate, Next.js, React 18
