# Plano: Criar Componente WebView Genérico

## Objetivo
Criar componente WebView genérico reutilizável em `src/atomic/templates/`, refatorando apenas `AirlineMilesWebView` para usá-lo.

---

## Estrutura Final

```
src/
├── atomic/templates/
│   └── GenericWebViewScreen/
│       ├── index.tsx           # Container (lógica)
│       ├── view.tsx            # View (apresentação)
│       └── Models/index.ts     # Types
├── hooks/
│   └── useGenericWebView.ts    # Hook de lógica comum
└── screens/
    └── AirlineMilesWebView/    # Refatorar para usar genérico
```

---

## Arquivos a Criar

### 1. `src/atomic/templates/GenericWebViewScreen/Models/index.ts`

```typescript
import { RefObject } from 'react';
import { WebViewProps } from 'react-native-webview';
import { WebViewErrorEvent } from 'react-native-webview/lib/WebViewTypes';

export interface GenericWebViewScreenProps {
  uri: string;
  title: string;
  webViewRef: RefObject<WebViewProps | null>;
  onBackPress: () => void;
  onError: (event: WebViewErrorEvent) => void;
  errorButtonOnPress: () => void;
  rightIcon?: string;
}
```

### 2. `src/atomic/templates/GenericWebViewScreen/view.tsx`

View com:
- BasicScreen (title, icons, scroll config)
- WebView com config padrão (mixedContentMode, domStorage, js, cookies, etc)
- Loading component
- Error component

### 3. `src/atomic/templates/GenericWebViewScreen/index.tsx`

Container simples que repassa props para view.

### 4. `src/hooks/useGenericWebView.ts`

```typescript
interface UseGenericWebViewParams {
  navigation: NavigationProp<any>;
  route: RouteProp<any>;
  screenTitle: string;
  fetchData: () => Promise<void> | void;
  resetData?: () => void;
  isLoading: boolean;
  isError: boolean;
  data: string | null; // redirectURL
}

// Retorna handlers e estados para o container
```

---

## Arquivos a Modificar

### `src/screens/AirlineMilesWebView/index.tsx`

Refatorar para usar `useGenericWebView` hook e `GenericWebViewScreen` template.

### `src/screens/AirlineMilesWebView/view.tsx`

**DELETAR** - Será substituído pelo template genérico.

---

## Ordem de Implementação

1. [ ] Criar `src/atomic/templates/GenericWebViewScreen/Models/index.ts`
2. [ ] Criar `src/atomic/templates/GenericWebViewScreen/view.tsx`
3. [ ] Criar `src/atomic/templates/GenericWebViewScreen/index.tsx`
4. [ ] Criar `src/hooks/useGenericWebView.ts`
5. [ ] Refatorar `src/screens/AirlineMilesWebView/index.tsx`
6. [ ] Deletar `src/screens/AirlineMilesWebView/view.tsx`

---

## Arquivos de Referência

| Arquivo | Propósito |
|---------|-----------|
| `src/screens/RewardProgramMarketplace/view.tsx` | Base para GenericWebViewScreen |
| `src/atomic/templates/BasicScreen/` | Padrão de estrutura de templates |
| `src/screens/AirlineMilesWebView/index.tsx` | Será refatorado |

---

## Resultado Esperado

**Antes**: 2 arquivos view.tsx duplicados (RewardProgramMarketplace + AirlineMilesWebView)

**Depois**: 1 template genérico, AirlineMilesWebView usa o genérico, RewardProgramMarketplace permanece inalterado
