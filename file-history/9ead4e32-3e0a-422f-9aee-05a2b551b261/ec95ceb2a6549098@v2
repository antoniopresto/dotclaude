# Plano: Criar Estrutura Harness para SPMAIS-33081

## Contexto

**Task:** SPMAIS-33081 - Resgate MktPlace Milhas aéreas (Webview)

**Objetivo:** Criar arquivo único `CLAUDE.md` consolidado com todas as instruções para execução da task.

## Pesquisa Realizada

### Anthropic Harness (Fontes)
- [Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Bloom Framework](https://alignment.anthropic.com/2025/bloom-auto-evals/)

---

## Estrutura a Criar

```
.harness/SPMAIS-33081-CASHBACK-MILHAS-WEBVIEW/
└── CLAUDE.md    # Arquivo único com todas as instruções
```

---

## Ação a Executar

1. [ ] Criar diretório `.harness/SPMAIS-33081-CASHBACK-MILHAS-WEBVIEW/`
2. [ ] Criar `CLAUDE.md` com conteúdo completo abaixo

---

## Conteúdo do CLAUDE.md

```markdown
# SPMAIS-33081 - Resgate MktPlace Milhas Aéreas (Webview)

## Objetivo
Implementar redirecionamento para WebView do MktPlace Milhas aéreas da Vertem quando o cliente escolher "Milhas aéreas" na tela Programa de Pontos.

## Referência
Seguir implementação do MktPlace loja (SPMAIS-29672). A diferença é usar `catalog=MILEAGE`.

---

## API

**Endpoint:**
```
GET /marketplace/v1/vertem/getToken?redirectTo=MARKETPLACE&catalog=MILEAGE
```

**Headers:** (já preenchidos pelo mecanismo do app)
- x-api-key, uuid, empresa, codigocanal, appversion, user-agent, devicename, lat, long, hash, accesstoken, codigocliente

**Response:**
```json
{
  "dados": {
    "redirectURL": "https://semparar-middleware-sso-hml.vertem.com/vertem/auth?..."
  },
  "status": {
    "codigoRetorno": 0,
    "mensagem": "Sucesso"
  }
}
```

---

## Features (Checklist)

### 1. Service Layer - Milhas Aéreas
- [ ] Criar `src/services/airlineMiles/api/index.ts` - Cliente HTTP
- [ ] Criar `src/services/airlineMiles/repository/index.ts` - Mapeamento de dados
- [ ] Criar `src/services/airlineMiles/services/index.ts` - Orquestração
- [ ] Criar `src/services/airlineMiles/store/index.ts` - Zustand slice
- [ ] Criar `src/services/airlineMiles/models/index.ts` - Tipos TypeScript
- [ ] Criar `src/services/airlineMiles/hooks/index.ts` - Hook de consumo
- [ ] Exportar em `src/services/airlineMiles/index.ts`

### 2. Screen WebView
- [ ] Criar `src/screens/AirlineMilesWebView/index.tsx` - Hook logic
- [ ] Criar `src/screens/AirlineMilesWebView/view.tsx` - Renderização WebView
- [ ] Criar `src/screens/AirlineMilesWebView/Models/index.ts` - Tipos
- [ ] Reutilizar padrão de `src/screens/RewardProgramMarketplace/`

### 3. Navegação
- [ ] Adicionar rota `AirlineMilesWebView` em `src/routes/Models/index.ts`
- [ ] Registrar screen em `src/routes/index.tsx`
- [ ] Atualizar `useCardBuilderWhereUseMyPoints` para navegar ao clicar em "Milhas aéreas"

### 4. Tagueamento (Analytics)
- [ ] Implementar `eventScreenViewV3` ao entrar na tela
- [ ] Implementar `eventSelectContent` ao clicar em "Milhas aéreas"

---

## Arquivos de Referência

| Arquivo | Propósito |
|---------|-----------|
| `src/screens/RewardProgramMarketplace/` | Screen WebView template |
| `src/redux/sagas/marketplace/getMarketplace.ts` | Lógica de chamada API (referência) |
| `src/hooks/custom/useCardBuilderWhereUseMyPoints/index.ts` | Hook de navegação a modificar |
| `src/screens/Points/data/index.ts` | Mapeamento `KEY_NAME_TO_ICON.AIRLINE_MILES` |
| `src/services/additionalCard/` | Exemplo de service layer com Zustand |
| `.harness/docs/1.Frontend_Style_Guide.md` | Guia de estilos obrigatório |

---

## Regras Obrigatórias

1. **Usar Zustand** - NÃO usar Redux/Sagas para novo código
2. **Hook Component Pattern** - Separar `index.tsx` (lógica) de `view.tsx` (UI)
3. **Tipos em Models/** - Interfaces separadas para Props, State, Return
4. **Código em inglês** - Nomes, comentários, documentação
5. **Fluxo de dados**: UI → hooks → services → repository → api

---

## Estrutura de Pastas Final

```
src/
├── services/
│   └── airlineMiles/
│       ├── api/index.ts
│       ├── repository/index.ts
│       ├── services/index.ts
│       ├── store/index.ts
│       ├── models/index.ts
│       ├── hooks/index.ts
│       └── index.ts
├── screens/
│   └── AirlineMilesWebView/
│       ├── index.tsx
│       ├── view.tsx
│       └── Models/index.ts
└── routes/
    ├── Models/index.ts (atualizar)
    └── index.tsx (atualizar)
```

---

## Validação Final

- [ ] Tela abre WebView com URL correta da Vertem
- [ ] Analytics dispara eventos corretos
- [ ] Navegação de volta funciona
- [ ] Loading state funciona
- [ ] Error state funciona
- [ ] TypeScript sem erros
- [ ] Seguiu Frontend_Style_Guide.md
```
