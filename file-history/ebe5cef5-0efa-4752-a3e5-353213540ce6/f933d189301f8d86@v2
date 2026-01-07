# Plano: Tornar HQ Produtivo (CRUD de Tasks)

## Problema

O HQ atualmente é apenas um **visualizador** - lê tasks do harness CLI mas:
1. Não tem UI para **adicionar** tasks
2. Não tem UI para **editar** tasks
3. Não tem UI para **deletar** tasks
4. Não inicializa o banco automaticamente

**Resultado:** Usuário abre projeto, Kanban mostra "No Tasks", sem opção de fazer nada.

---

## Solução: Adicionar CRUD Completo

### Fase 1: TaskModal - Modal para Add/Edit Task

**Novo arquivo:** `src/components/TaskModal.tsx`

Modal com PatternFly:
- Título (TextInput, obrigatório)
- Descrição (TextArea, opcional)
- Status (Select: BACKLOG, TODO, DOING, REVIEW, QA, DONE)
- Prioridade (Select: low, medium, high, critical)
- Categoria (TextInput, opcional)

Props:
```typescript
type TaskModalProps = {
  isOpen: boolean;
  onClose: () => void;
  onSave: (task: TaskData) => Promise<void>;
  task?: Feature; // se existir, é modo edição
  projectPath: string;
};
```

### Fase 2: Botão "Add Task" no Kanban

**Arquivo:** `src/components/KanbanBoard.tsx`

- Adicionar botão "Add Task" no header do board
- Ao clicar, abre TaskModal em modo criação
- Callback `onAddTask` prop

### Fase 3: Init Automático do Banco

**Arquivo:** `src/components/ProjectSelector.tsx`

Quando usuário seleciona pasta:
1. Verificar se `.harness/harness.db` existe via novo comando Tauri
2. Se não existe, rodar `harness init`
3. Mostrar loading durante inicialização

**Novo comando Tauri:** `check_harness_db_exists`

### Fase 4: Editar Task

**Arquivo:** `src/components/KanbanCard.tsx`

- Adicionar botão de editar (ícone lápis) no card
- Ao clicar, abre TaskModal em modo edição
- Reutiliza mesmo modal da Fase 1

### Fase 5: Deletar Task

**Arquivo:** `src/components/KanbanCard.tsx`

- Adicionar botão de deletar (ícone lixeira) no card
- Modal de confirmação antes de deletar
- Chama `harness task delete <id>`

### Fase 6: Integrar CRUD no App.tsx

**Arquivo:** `src/App.tsx`

Adicionar handlers:
- `handleAddTask(taskData)` → `harness task add ...`
- `handleUpdateTask(id, taskData)` → `harness task update ...`
- `handleDeleteTask(id)` → `harness task delete ...`

Refresh automático após cada operação.

### Fase 7: Drag-and-Drop entre Colunas

**Arquivo:** `src/components/KanbanBoard.tsx`

- Usar HTML5 drag-and-drop nativo (já usado no TabBar)
- `draggable` nos cards
- `onDragStart`, `onDragOver`, `onDrop` nas colunas
- Ao soltar card em outra coluna, atualizar status:
```typescript
await invoke('run_harness_command', {
  projectPath,
  args: ['task', 'update', taskId, '--status', newStatus]
});
```

---

## Arquivos a Modificar/Criar

| Arquivo | Ação |
|---------|------|
| `src/components/TaskModal.tsx` | **CRIAR** |
| `src/components/KanbanBoard.tsx` | Adicionar botão Add |
| `src/components/KanbanCard.tsx` | Adicionar botões Edit/Delete |
| `src/components/ProjectSelector.tsx` | Init automático |
| `src/App.tsx` | Handlers CRUD + refresh |
| `src-tauri/src/lib.rs` | Comando check_harness_db_exists |

---

## Comandos harness CLI a Usar

```bash
# Criar task
harness task add "Título" --description "Desc" --status TODO --priority high

# Editar task
harness task update <id> --title "Novo" --status DOING --priority medium

# Deletar task
harness task delete <id>

# Listar tasks (já usado)
harness task list --format json
```

---

## Ordem de Execução

1. **Fase 1** - TaskModal (componente base)
2. **Fase 2** - Botão Add no Kanban
3. **Fase 6** - Handlers CRUD no App.tsx
4. **Fase 3** - Init automático do banco
5. **Fase 4** - Editar task
6. **Fase 5** - Deletar task
7. **Fase 7** - Drag-and-drop entre colunas

---

## Validação

1. Abrir projeto sem tasks → botão "Add Task" visível
2. Clicar Add → modal abre
3. Preencher e salvar → task aparece no Kanban
4. Clicar editar → modal com dados preenchidos
5. Alterar e salvar → mudanças refletidas
6. Clicar deletar → confirmação → task some
7. Arrastar task de TODO para DOING → status atualizado
