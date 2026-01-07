# Plano: Migrar para MCP Automation para Testes Visuais

## Contexto
Playwright MCP não funciona corretamente com apps Tauri nativos. Precisamos de alternativa para testes visuais.

## Solução Escolhida
**MCP Automation** - já disponível no ambiente, captura screenshots do desktop.

## ⚠️ Requisito: Permissão de Tela no macOS
O terminal/Claude Code precisa de permissão em:
**System Settings > Privacy & Security > Screen Recording**

Adicionar o terminal usado (Terminal.app, iTerm2, Warp, etc.)

## Ferramentas Disponíveis
```
mcp__automation__screenshot      → Captura tela (full, region, window)
mcp__automation__mouseClick      → Clique em coordenadas
mcp__automation__mouseDoubleClick
mcp__automation__type            → Digitar texto
mcp__automation__keyControl      → Atalhos de teclado
mcp__automation__getWindows      → Listar janelas abertas
mcp__automation__getActiveWindow → Janela ativa
mcp__automation__windowControl   → Focar/mover/redimensionar janela
mcp__automation__screenInfo      → Info da tela
```

---

## Tarefas

### 1. Testar MCP Automation
- [ ] Verificar se `mcp__automation__screenshot` funciona
- [ ] Testar captura por janela (mode: "window")
- [ ] Verificar `mcp__automation__getWindows` para listar janelas

### 2. Atualizar CLAUDE.md
Substituir seção "MCP VISUAL TESTING" com novo protocolo:

```markdown
## MCP VISUAL TESTING (MCP Automation)

### Por que MCP Automation?
Playwright não funciona com apps Tauri nativos. MCP Automation captura a tela do desktop diretamente.

### Protocolo de Teste

#### Passo 1: Iniciar o app (background)
bun tauri dev  # run_in_background: true

#### Passo 2: Aguardar startup
mcp__automation__sleep ms=5000

#### Passo 3: Listar janelas
mcp__automation__getWindows

#### Passo 4: Focar janela do app
mcp__automation__windowControl action="focus" windowTitle="HQ"

#### Passo 5: Screenshot
mcp__automation__screenshot mode="window" windowName="HQ"

#### Passo 6: Analisar visualmente
- [ ] Conteúdo visível?
- [ ] Layout correto?
- [ ] Sem erros visuais?
```

### 3. Atualizar .harness/progress.txt
Documentar a mudança de Playwright → MCP Automation.

---

## Arquivos a Modificar
1. `/Users/anotonio.silva/antonio/HQ/CLAUDE.md` - Seção de testes visuais
2. `/Users/anotonio.silva/antonio/HQ/.harness/progress.txt` - Registrar mudança

## Limitações Conhecidas
- Captura desktop inteiro se não especificar janela
- Pode capturar janelas sobrepostas
- Requer que a janela do app esteja visível (não minimizada)

## Próximos Passos (após permissão concedida)
1. Testar `mcp__automation__screenshot` funciona
2. Atualizar CLAUDE.md com novo protocolo
3. Atualizar .harness/progress.txt
4. Commitar mudanças

## Status
✅ Usuário confirmou que vai conceder permissão de Screen Recording
⏳ Aguardando permissão para testar e implementar
