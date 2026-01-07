# Relatório de Integridade do Sistema Harness - Análise Profunda

## Entendimento do Harness (Anthropic)

Baseado em [Effective harnesses for long-running agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents):

> "The key insight was finding a way for agents to quickly understand the state of work when starting with a fresh context window."

### Hierarquia de Documentação no Harness

1. **CLAUDE.md** → Documento AUTORITATIVO (regras do projeto)
2. **features.json** → FONTE DE VERDADE (estado das features)
3. **claude-progress.txt** → Log de sessões (histórico)
4. **Outros arquivos** → Devem estar ALINHADOS com os 3 acima

### O que CLAUDE.md define (AUTORITATIVO):
- **Produção:** `apps/canvas` (React 18 + R3F 8.x + BlueprintJS 6)
- **POC:** `URGENT_POC/` (arquivado, referência visual)
- **Packages:** Apenas `@mms/toolkit` mencionado
- **Stack:** Vite 5.x, React 18.3.1, BlueprintJS 6.1.0

---

## Resumo Executivo

Analisando sob a ótica do harness, o problema não é "dois stacks conflitantes" - é que **documentação auxiliar não foi atualizada** após a decisão arquitetural documentada em CLAUDE.md e features.json.

---

## Classificação dos Arquivos no Harness

### ✅ Arquivos AUTORITATIVOS (corretos)

| Arquivo | Status | Função no Harness |
|---------|--------|-------------------|
| **CLAUDE.md** | ✅ CORRETO | Documento autoritativo - define stack e regras |
| **features.json** | ✅ CORRETO | Fonte de verdade - estado das features |
| **claude-progress.txt** | ✅ CORRETO | Log de sessões - histórico do projeto |
| **docs/DOMAIN.md** | ✅ CORRETO | Documentação de domínio |
| **docs/REQUIREMENTS.md** | ✅ CORRETO | Requisitos do RFQ |
| **docs/UX_SPECIFICATION.md** | ✅ CORRETO | Especificação UX |

### ⚠️ Arquivos AUXILIARES (desalinhados)

| Arquivo | Problema | Ação Necessária |
|---------|----------|-----------------|
| **README.md** | Menciona React 19, Astro, apps/system | Alinhar com CLAUDE.md |
| **CONTINUE.md** | Referencia F016 (POC) | Mudar para F102 (produção) |
| **design/README.md** | Paths apontam para packages/gl-engine | Atualizar para apps/canvas |

### ❌ Arquivos LEGADOS (precisam de decisão)

| Arquivo | Problema | Opções |
|---------|----------|--------|
| **INITIAL_PROMPT.md** | Requisitos originais superados | Marcar como histórico |
| **PROMPT.md** | Português, comandos pnpm | Traduzir ou arquivar |
| **CLAUDE_NOTES.md** | Mix de info antiga/nova | Limpar seções Astro |

### 🗑️ Código LEGADO (não documentado em CLAUDE.md)

| Código | Status | Ação |
|--------|--------|------|
| **apps/system** | Existe mas não mencionado | Ignorar ou deletar |
| **packages/gl-engine** | React 19 only | Ignorar (incompatível) |
| **packages/ui** | React 19 only | Ignorar (incompatível) |
| **packages/domain** | Sem React | Disponível se necessário |

---

## Análise Detalhada por Arquivo

### 1. INITIAL_PROMPT.md - PRECISA DE DECISÃO
**Status:** Documento original do projeto que especifica:
- React 19 (mas produção usa React 18)
- Astro (mas produção usa Vite)
- Tailwind CSS v4 (mas produção usa BlueprintJS)
- apps/system como entry point (mas documentação diz apps/canvas)

**Problema:** Não está marcado como "histórico" ou "arquivado". Alguém lendo pode pensar que são os requisitos atuais.

**Opções:**
1. Arquivar com nota clara "HISTORICAL - NOT CURRENT REQUIREMENTS"
2. Atualizar para refletir o stack atual
3. Deletar (perder história do projeto)

### 2. README.md (raiz) - CRÍTICO
**Erros identificados:**
- Linha 21: "React 19" → Deveria ser "React 18.3.1"
- Linha 20: "Astro (Static/SPA)" → Deveria ser "Vite 5.x" (ou 7.2.4)
- Linha 22: "Tailwind CSS v4" → Deveria ser "BlueprintJS 6.1.0"
- Linhas 29-36: Estrutura de projeto desatualizada

### 3. CONTINUE.md - MISLEADING
**Erro:** Linha 12 diz "Find first feature where passes: false (likely F016)"
**Realidade:** F016 é feature do POC arquivado. Next feature é F102.

### 4. PROMPT.md - OBSOLETO
**Problemas:**
- Inteiramente em Português (viola regra "English only")
- Referencia comandos pnpm (projeto usa bun)
- Referencia feature IDs antigos (setup-001 a setup-008)

### 5. CLAUDE_NOTES.md - PARCIALMENTE DESATUALIZADO
**Problemas:**
- Seção "Astro + React Integration" não mais aplicável
- Referência a "React 19 compatibility" quando stack é React 18
- Referência a Tailwind CSS v4

### 6. claude-progress.txt - CONFUSO
**Problema:** Múltiplas sessões na mesma data (2025-12-15) com informações contraditórias:
- Sessões antigas mencionam "React 19", "Astro"
- Sessões recentes mencionam "React 18", "Vite", "BlueprintJS"
- Difícil entender cronologia e estado atual

---

## Incompatibilidades de Packages

### packages/gl-engine
- Usa `@react-three/fiber 9.0.0-rc.4` (REQUER React 19)
- apps/canvas usa React 18
- **INCOMPATÍVEL** - gl-engine não pode ser usado com apps/canvas

### packages/ui
- Usa React 19+ (peer dependency)
- apps/canvas usa React 18
- **INCOMPATÍVEL**

### packages/toolkit
- React 18 || 19 compatible ✅
- Único package que funciona com ambos stacks

### packages/domain
- Sem dependência React ✅
- Funciona com qualquer stack

---

## Estado Real do Código vs Documentação

| Componente | Documentado | Realidade |
|------------|-------------|-----------|
| Entry Point | apps/canvas | Root script executa apps/system |
| React Version | 18.3.1 | apps/canvas: 18 ✅, apps/system: 19 |
| Build Tool | Vite 5.x | Vite 7.2.4 (mais novo) |
| UI Library | BlueprintJS | Correto em apps/canvas |
| apps/canvas | Production app | Skeleton vazio |
| URGENT_POC | Archived | Único código funcional |
| gl-engine | Not mentioned | Existe mas incompatível |
| apps/system | Not mentioned | Existe com stack diferente |

---

## Conclusão: A Decisão JÁ FOI TOMADA

Baseado no conceito de harness da Anthropic, **não há decisão a ser tomada**. Os documentos autoritativos (CLAUDE.md e features.json) JÁ DEFINEM a arquitetura:

### Arquitetura Oficial (definida em CLAUDE.md):
- **Produção:** `apps/canvas` (React 18 + R3F 8.x + BlueprintJS 6)
- **POC:** `URGENT_POC/` (arquivado)
- **Next Feature:** F102 (adicionar R3F Canvas)

### O que precisa ser ALINHADO:
Todos os arquivos auxiliares devem refletir essa decisão já documentada.

---

## Plano de Correção

### 1. README.md (raiz)
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/README.md`
**Ações:**
- Linha 20-24: Atualizar tech stack para Vite + React 18 + BlueprintJS
- Linhas 29-36: Atualizar estrutura para apps/canvas
- Adicionar referência ao POC arquivado

### 2. CONTINUE.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/CONTINUE.md`
**Ações:**
- Linha 12: Mudar "F016" para "F102"
- Atualizar para refletir production features (F101+)

### 3. INITIAL_PROMPT.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/INITIAL_PROMPT.md`
**Ação:** DELETAR
- Remover arquivo completamente
- Remover referências em outros arquivos (se houver)

### 4. PROMPT.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/PROMPT.md`
**Ação:** DELETAR
- Remover arquivo completamente (conteúdo obsoleto em português)

### 5. CLAUDE_NOTES.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/CLAUDE_NOTES.md`
**Ações:**
- Remover/atualizar seção "Astro + React Integration"
- Atualizar referências React 19 → React 18
- Remover referências Tailwind (agora é BlueprintJS)

### 6. design/README.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/design/README.md`
**Ações:**
- Atualizar paths de packages/gl-engine → apps/canvas/src
- Atualizar checklist (desmarcar items não implementados em apps/canvas)

### 7. packages/toolkit/README.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/packages/toolkit/README.md`
**Ações:**
- Linha 1-9: Corrigir "@belt/toolkit" → "@mms/toolkit"

### 8. apps/canvas/README.md
**Arquivo:** `/Users/anotonio.silva/antonio/mms/system/apps/canvas/README.md`
**Ações:**
- Substituir template Vite genérico por documentação específica do MMS

---

## Código Legado - DELETAR

### 9. apps/system
**Diretório:** `/Users/anotonio.silva/antonio/mms/system/apps/system`
**Ação:** DELETAR
- App Astro + React 19 não usado
- Não documentado em CLAUDE.md

### 10. packages/gl-engine
**Diretório:** `/Users/anotonio.silva/antonio/mms/system/packages/gl-engine`
**Ação:** DELETAR
- Requer React 19 (incompatível com apps/canvas)
- Não mencionado em CLAUDE.md

### 11. packages/ui
**Diretório:** `/Users/anotonio.silva/antonio/mms/system/packages/ui`
**Ação:** DELETAR
- Requer React 19 (incompatível com apps/canvas)
- Não mencionado em CLAUDE.md

### 12. packages/domain
**Diretório:** `/Users/anotonio.silva/antonio/mms/system/packages/domain`
**Ação:** DELETAR
- Não mencionado em CLAUDE.md como parte do stack atual
- apps/canvas vai ter seus próprios tipos em src/data/

---

## Ordem de Execução

### Fase 1: Deletar código/arquivos obsoletos
1. `rm /Users/anotonio.silva/antonio/mms/system/INITIAL_PROMPT.md`
2. `rm /Users/anotonio.silva/antonio/mms/system/PROMPT.md`
3. `rm -rf /Users/anotonio.silva/antonio/mms/system/apps/system`
4. `rm -rf /Users/anotonio.silva/antonio/mms/system/packages/gl-engine`
5. `rm -rf /Users/anotonio.silva/antonio/mms/system/packages/ui`
6. `rm -rf /Users/anotonio.silva/antonio/mms/system/packages/domain`

### Fase 2: Atualizar documentação
7. **README.md** - Alinhar com CLAUDE.md
8. **CONTINUE.md** - F016 → F102
9. **CLAUDE_NOTES.md** - Limpar refs obsoletas
10. **design/README.md** - Atualizar paths
11. **packages/toolkit/README.md** - @belt → @mms
12. **apps/canvas/README.md** - Doc específica

### Fase 3: Atualizar configurações (se necessário)
13. **Root package.json** - Remover refs a packages deletados
14. **turbo.json** - Atualizar se existir refs

---

## Validação Final

Após correções, verificar:
- [ ] Todos os arquivos referenciam apps/canvas como produção
- [ ] Stack consistente: Vite + React 18 + BlueprintJS + R3F 8.x
- [ ] Feature IDs corretos: F101+ para produção
- [ ] Linguagem: Todos em inglês
- [ ] Comandos: bun (não pnpm)
- [ ] INITIAL_PROMPT.md claramente marcado como histórico
