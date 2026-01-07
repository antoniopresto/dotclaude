# Plano: claude-search - Busca Interativa no Histórico do Claude Code

## Objetivo
Criar ferramenta `claude-search` (alias `cs`) para buscar mensagens em chats anteriores do Claude Code com:
- Busca fuzzy via fzf
- Preview paginado com contexto da sessão
- Opção de abrir/resumir conversa com Enter

## Dados Descobertos

| Arquivo | Conteúdo |
|---------|----------|
| `~/.claude/history.jsonl` | ~1972 mensagens, 325 sessões, JSONL |
| `~/.claude/debug/{sessionId}.txt` | Logs detalhados por sessão |

**Estrutura de cada entrada:**
```json
{
  "display": "texto da mensagem",
  "timestamp": 1764096884910,
  "project": "/caminho/projeto",
  "sessionId": "uuid"
}
```

**Comando para resumir:** `claude --resume <sessionId>`

## Implementação

### Arquivo: `~/.local/bin/claude-search`

Script bash standalone com:

1. **Cache processado** (`/tmp/claude-search-cache-*.tsv`)
   - TTL 60s para performance
   - Formato: `sessionId\tdata\tprojeto\tmensagem`

2. **Interface fzf**
   - Preview: mensagens da sessão + metadados
   - Atalhos: Enter (resumir), Ctrl-Y (copiar), Ctrl-L (debug log)

3. **Ações**
   - Enter: `cd $project && claude --resume $sessionId`
   - Ctrl-Y: copia sessionId para clipboard
   - Ctrl-L: abre debug log no less

### Alias no `~/.zshrc`
```bash
alias cs='claude-search'
```

## Arquivos a Criar/Modificar

| Arquivo | Ação |
|---------|------|
| `~/.local/bin/claude-search` | Criar (script principal) |
| `~/.zshrc` | Adicionar alias `cs` |

## Dependências
- [x] fzf 0.67.0 (instalado)
- [x] jq 1.7.1 (instalado)
- [x] `claude --resume` (confirmado)

## Funcionalidades

### Uso Básico
```bash
cs              # abre busca interativa
cs "docker"     # busca com termo inicial
cs -p projeto   # filtra por projeto
```

### Atalhos fzf
| Tecla | Ação |
|-------|------|
| `Enter` | Resumir conversa no projeto original |
| `Ctrl-Y` | Copiar sessionId |
| `Ctrl-L` | Abrir debug log |
| `Ctrl-R` | Recarregar cache |
| `Ctrl-/` | Toggle preview |

### Preview
- Lista todas as mensagens da sessão
- Mostra projeto, contagem de mensagens
- Indica se debug log existe

## Edge Cases Tratados
- Mensagens com newlines → substituídas por espaço
- Mensagens longas → truncadas no cache, completas no preview
- Projeto removido → fallback para $HOME
- Cache desatualizado → TTL + Ctrl-R reload

## Passos de Execução

1. Criar diretório `~/.local/bin` (se não existir)
2. Criar script `claude-search` com lógica completa
3. Dar permissão de execução
4. Adicionar alias `cs` ao `~/.zshrc`
5. Testar com `source ~/.zshrc && cs`
