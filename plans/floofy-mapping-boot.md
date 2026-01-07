# F012: Native UX Polish - Implementation Plan

## Objective
Transform HQ from a "web app in a window" to a native-feeling macOS application.

---

## Research Summary

### Sources Consulted
- [Tauri Window Customization](https://v2.tauri.app/learn/window-customization/)
- [window-vibrancy crate](https://github.com/tauri-apps/window-vibrancy)
- [tauri-plugin-prevent-default](https://github.com/ferreira-tb/tauri-plugin-prevent-default)
- [Tauri Global Shortcuts](https://v2.tauri.app/plugin/global-shortcut/)
- [Tauri Menu API](https://v2.tauri.app/reference/javascript/api/namespacemenu/)
- [Making Electron Apps Feel Native on Mac](https://getlotus.app/21-making-electron-apps-feel-native-on-mac)
- [Motion (Framer Motion)](https://motion.dev/)
- [NSVisualEffectView Materials](https://developer.apple.com/documentation/appkit/nsvisualeffectview/material)

---

## User Requirements (Confirmed)

- **Prioridade:** Todas as fases em ordem
- **Animações:** Incluir Motion (spring physics)
- **Plataforma:** macOS only
- **Foco especial:**
  - Menu bar atual tem cara de "web app" (HQ, Edit...) → precisa ser nativo macOS
  - Context menu é o default do browser → precisa ser nativo
  - DevTools pode ser inspecionado via context menu/atalho → desabilitar em produção

---

## Implementation Phases

### Phase 0: Native Menu Bar (macOS style)

**Problema atual:** O menu "HQ, Edit..." parece web, não nativo.

**File: `src-tauri/src/lib.rs`**
```rust
use tauri::menu::{Menu, Submenu, MenuItem, PredefinedMenuItem};

fn create_native_menu(app: &tauri::AppHandle) -> tauri::Result<Menu<tauri::Wry>> {
    // macOS standard menu structure
    let app_menu = Submenu::with_items(app, "HQ", true, &[
        &MenuItem::with_id(app, "about", "About HQ", true, None::<&str>)?,
        &PredefinedMenuItem::separator(app)?,
        &MenuItem::with_id(app, "settings", "Settings...", true, Some("CmdOrCtrl+,"))?,
        &PredefinedMenuItem::separator(app)?,
        &PredefinedMenuItem::services(app, None)?,
        &PredefinedMenuItem::separator(app)?,
        &PredefinedMenuItem::hide(app, None)?,
        &PredefinedMenuItem::hide_others(app, None)?,
        &PredefinedMenuItem::show_all(app, None)?,
        &PredefinedMenuItem::separator(app)?,
        &PredefinedMenuItem::quit(app, None)?,
    ])?;

    let file_menu = Submenu::with_items(app, "File", true, &[
        &MenuItem::with_id(app, "new_project", "Open Project...", true, Some("CmdOrCtrl+O"))?,
        &PredefinedMenuItem::separator(app)?,
        &MenuItem::with_id(app, "new_tab", "New Tab", true, Some("CmdOrCtrl+T"))?,
        &MenuItem::with_id(app, "close_tab", "Close Tab", true, Some("CmdOrCtrl+W"))?,
    ])?;

    let edit_menu = Submenu::with_items(app, "Edit", true, &[
        &PredefinedMenuItem::undo(app, None)?,
        &PredefinedMenuItem::redo(app, None)?,
        &PredefinedMenuItem::separator(app)?,
        &PredefinedMenuItem::cut(app, None)?,
        &PredefinedMenuItem::copy(app, None)?,
        &PredefinedMenuItem::paste(app, None)?,
        &PredefinedMenuItem::select_all(app, None)?,
    ])?;

    let view_menu = Submenu::with_items(app, "View", true, &[
        &MenuItem::with_id(app, "toggle_sidebar", "Toggle Sidebar", true, Some("CmdOrCtrl+\\"))?,
        &MenuItem::with_id(app, "toggle_logs", "Toggle Logs", true, Some("CmdOrCtrl+J"))?,
        &PredefinedMenuItem::separator(app)?,
        &PredefinedMenuItem::fullscreen(app, None)?,
    ])?;

    let window_menu = Submenu::with_items(app, "Window", true, &[
        &PredefinedMenuItem::minimize(app, None)?,
        &PredefinedMenuItem::maximize(app, None)?,
        &PredefinedMenuItem::separator(app)?,
        &MenuItem::with_id(app, "prev_tab", "Previous Tab", true, Some("CmdOrCtrl+Shift+["))?,
        &MenuItem::with_id(app, "next_tab", "Next Tab", true, Some("CmdOrCtrl+Shift+]"))?,
    ])?;

    let help_menu = Submenu::with_items(app, "Help", true, &[
        &MenuItem::with_id(app, "docs", "Documentation", true, None::<&str>)?,
        &MenuItem::with_id(app, "github", "GitHub Repository", true, None::<&str>)?,
    ])?;

    Menu::with_items(app, &[
        &app_menu,
        &file_menu,
        &edit_menu,
        &view_menu,
        &window_menu,
        &help_menu,
    ])
}
```

**Effort:** 1 hour

---

### Phase 1: CSS Foundation (No dependencies)

**File: `src/index.css`**

```css
/* Native-feel base styles */
:root {
  font-family: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
  font-size: 14px; /* Native apps use 13-14px, not 16px */
}

/* Disable text selection on UI elements */
*:not(input):not(textarea):not([contenteditable="true"]):not(.selectable) {
  user-select: none;
  -webkit-user-select: none;
}

/* Allow selection only on content areas */
.selectable, pre, code, .log-content {
  user-select: text;
  -webkit-user-select: text;
}

/* Default cursor everywhere (native apps don't use pointer) */
*, a, button {
  cursor: default;
}

/* Pointer only for external links */
a[href^="http"] {
  cursor: pointer;
}

/* Focus-visible: show outline only on keyboard navigation */
*:focus {
  outline: none;
}
*:focus-visible {
  outline: 2px solid var(--pf-t--global--border--color--clicked);
  outline-offset: 2px;
}

/* Disable image/element dragging */
img, svg, [draggable="false"] {
  -webkit-user-drag: none;
  user-drag: none;
}

/* Prevent overscroll bounce */
html, body {
  overscroll-behavior: none;
}

/* Titlebar drag region */
.titlebar-drag {
  -webkit-app-region: drag;
}
.titlebar-no-drag {
  -webkit-app-region: no-drag;
}

/* Transparent background for vibrancy */
html, body {
  background: transparent;
}
```

**Effort:** 30 min

---

### Phase 2: Disable Browser Behaviors (Rust plugin)

**File: `src-tauri/Cargo.toml`**
```toml
tauri-plugin-prevent-default = "2.1"
```

**File: `src-tauri/src/lib.rs`**
```rust
use tauri_plugin_prevent_default::Flags;

// Disable browser shortcuts except dev tools in debug mode
#[cfg(debug_assertions)]
let prevent = tauri_plugin_prevent_default::Builder::new()
    .with_flags(Flags::all() - Flags::DEV_TOOLS - Flags::RELOAD)
    .build();

#[cfg(not(debug_assertions))]
let prevent = tauri_plugin_prevent_default::init();

tauri::Builder::default()
    .plugin(prevent)
    // ...
```

**Disables:**
- Cmd+F (find)
- Cmd+P (print)
- Cmd+G (find next)
- Cmd+[+/-] (zoom)
- Right-click context menu (we'll add our own native one)
- F5/Cmd+R reload (in production)
- Pinch-to-zoom

**Effort:** 15 min

---

### Phase 3: Window Vibrancy (macOS blur effect)

**File: `src-tauri/Cargo.toml`**
```toml
window-vibrancy = "0.7"
```

**File: `src-tauri/tauri.conf.json`**
```json
{
  "app": {
    "macOSPrivateApi": true,
    "windows": [{
      "transparent": true,
      "decorations": true,
      "titleBarStyle": "Overlay",
      "hiddenTitle": true
    }]
  }
}
```

**File: `src-tauri/src/lib.rs`**
```rust
use window_vibrancy::{apply_vibrancy, NSVisualEffectMaterial};

fn setup_window(app: &tauri::App) -> Result<(), Box<dyn std::error::Error>> {
    let window = app.get_webview_window("main").unwrap();

    #[cfg(target_os = "macos")]
    apply_vibrancy(&window, NSVisualEffectMaterial::Sidebar, None, None)?;

    Ok(())
}
```

**NSVisualEffectMaterial options:**
- `Sidebar` - Standard sidebar blur (recommended)
- `HudWindow` - Darker, more contrast
- `FullScreenUI` - Full screen overlay style
- `ContentBackground` - Subtle content area blur

**Effort:** 45 min

---

### Phase 4: Custom Context Menus (Notion-style, using PatternFly)

**Approach:** Use PatternFly's `Menu` + `Popper` components (already installed!) instead of native Tauri menus. This gives us full control over styling and matches Notion/Linear UX.

**New file: `src/components/ContextMenu.tsx`**
```typescript
import { Menu, MenuList, MenuItem, MenuGroup, Divider, Popper } from '@patternfly/react-core';
import { useEffect, useRef, useState } from 'react';

interface ContextMenuItem {
  id: string;
  label: string;
  shortcut?: string;
  icon?: React.ReactNode;
  danger?: boolean;
  disabled?: boolean;
  onClick: () => void;
}

interface ContextMenuProps {
  items: ContextMenuItem[];
  children: React.ReactNode;
}

export function ContextMenu({ items, children }: ContextMenuProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [position, setPosition] = useState({ x: 0, y: 0 });
  const menuRef = useRef<HTMLDivElement>(null);

  const handleContextMenu = (e: React.MouseEvent) => {
    e.preventDefault();
    setPosition({ x: e.clientX, y: e.clientY });
    setIsOpen(true);
  };

  // Close on click outside or Escape
  useEffect(() => {
    const handleClickOutside = () => setIsOpen(false);
    const handleEscape = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setIsOpen(false);
    };

    if (isOpen) {
      document.addEventListener('click', handleClickOutside);
      document.addEventListener('keydown', handleEscape);
    }
    return () => {
      document.removeEventListener('click', handleClickOutside);
      document.removeEventListener('keydown', handleEscape);
    };
  }, [isOpen]);

  return (
    <>
      <div onContextMenu={handleContextMenu}>{children}</div>
      {isOpen && (
        <div
          ref={menuRef}
          style={{
            position: 'fixed',
            left: position.x,
            top: position.y,
            zIndex: 9999
          }}
        >
          <Menu>
            <MenuList>
              {items.map(item => (
                <MenuItem
                  key={item.id}
                  isDanger={item.danger}
                  isDisabled={item.disabled}
                  onClick={() => { item.onClick(); setIsOpen(false); }}
                >
                  {item.icon}
                  {item.label}
                  {item.shortcut && <span className="context-menu-shortcut">{item.shortcut}</span>}
                </MenuItem>
              ))}
            </MenuList>
          </Menu>
        </div>
      )}
    </>
  );
}
```

**CSS for shortcuts display:**
```css
.context-menu-shortcut {
  margin-left: auto;
  padding-left: 24px;
  opacity: 0.6;
  font-size: 12px;
}
```

**Usage example:**
```typescript
<ContextMenu items={[
  { id: 'copy', label: 'Copy', shortcut: '⌘C', onClick: handleCopy },
  { id: 'paste', label: 'Paste', shortcut: '⌘V', onClick: handlePaste },
  { id: 'delete', label: 'Delete', danger: true, onClick: handleDelete },
]}>
  <KanbanCard {...props} />
</ContextMenu>
```

**Effort:** 1.5 hours

---

### Phase 5: Configurable Keybindings (VSCode-style)

**Design:** User-configurable keyboard shortcuts via JSON file, exactly like VSCode's `keybindings.json`.

**File: `src/config/defaultKeybindings.json`**
```json
[
  { "key": "cmd+t", "command": "tab.new" },
  { "key": "cmd+w", "command": "tab.close" },
  { "key": "cmd+shift+[", "command": "tab.previous" },
  { "key": "cmd+shift+]", "command": "tab.next" },
  { "key": "cmd+,", "command": "settings.open" },
  { "key": "cmd+k", "command": "commandPalette.open" },
  { "key": "cmd+\\", "command": "sidebar.toggle" },
  { "key": "cmd+j", "command": "logs.toggle" },
  { "key": "cmd+o", "command": "project.open" },
  { "key": "escape", "command": "modal.close", "when": "modalOpen" }
]
```

**File: `src/config/keybindingsSchema.ts`**
```typescript
export interface Keybinding {
  key: string;           // "cmd+t", "ctrl+shift+k", etc.
  command: string;       // Command ID to execute
  when?: string;         // Optional context condition
  args?: unknown;        // Optional arguments for command
}

// VSCode-style key notation
// - cmd/ctrl → platform-aware (Cmd on macOS, Ctrl on Windows/Linux)
// - shift, alt, meta
// - Single keys: a-z, 0-9, f1-f12, escape, enter, tab, space, etc.
// - Combined: cmd+shift+k, ctrl+alt+delete

export const KEY_MAP: Record<string, string> = {
  'cmd': 'Meta',
  'ctrl': 'Control',
  'alt': 'Alt',
  'shift': 'Shift',
  'escape': 'Escape',
  'enter': 'Enter',
  'tab': 'Tab',
  'space': ' ',
  'backspace': 'Backspace',
  'delete': 'Delete',
  // ... etc
};
```

**File: `src/hooks/useKeybindings.ts`**
```typescript
import { useEffect } from 'react';
import defaultKeybindings from '../config/defaultKeybindings.json';

type CommandHandler = (args?: unknown) => void;

const commandRegistry = new Map<string, CommandHandler>();

export function registerCommand(id: string, handler: CommandHandler) {
  commandRegistry.set(id, handler);
}

export function useKeybindings() {
  useEffect(() => {
    // Load user overrides from localStorage or file
    const userKeybindings = loadUserKeybindings();
    const keybindings = mergeKeybindings(defaultKeybindings, userKeybindings);

    const handleKeyDown = (e: KeyboardEvent) => {
      const pressed = buildKeyString(e); // "cmd+shift+t"
      const binding = keybindings.find(b => normalizeKey(b.key) === pressed);

      if (binding && checkWhenClause(binding.when)) {
        e.preventDefault();
        const handler = commandRegistry.get(binding.command);
        if (handler) handler(binding.args);
      }
    };

    window.addEventListener('keydown', handleKeyDown);
    return () => window.removeEventListener('keydown', handleKeyDown);
  }, []);
}

function buildKeyString(e: KeyboardEvent): string {
  const parts: string[] = [];
  if (e.metaKey) parts.push('cmd');
  if (e.ctrlKey) parts.push('ctrl');
  if (e.altKey) parts.push('alt');
  if (e.shiftKey) parts.push('shift');
  parts.push(e.key.toLowerCase());
  return parts.join('+');
}
```

**User keybindings file:** `~/.config/hq/keybindings.json` (or via Tauri app data)

**Benefits:**
- Users can customize any shortcut
- Supports "when" clauses for context-aware shortcuts
- Same format as VSCode (familiar to developers)
- Hot-reload when file changes (via file watcher)

**Effort:** 2 hours

---

### Phase 6: Spring Animations (Optional polish)

**Install:**
```bash
bun add motion
```

**File: `src/components/AnimatedCard.tsx`**
```typescript
import { motion } from 'motion/react';

export function AnimatedCard({ children }) {
  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ type: "spring", stiffness: 300, damping: 30 }}
    >
      {children}
    </motion.div>
  );
}
```

**Key animations:**
- Tab switching: spring with `stiffness: 400, damping: 30`
- Card expand/collapse: `type: "spring", bounce: 0.2`
- Panel resize: `type: "tween", ease: "easeOut"`

**Effort:** 2 hours (apply across components)

---

### Phase 7: Focus/Blur Window State

**File: `src-tauri/src/lib.rs`**
```rust
use tauri::Manager;

window.on_window_event(|event| {
    match event {
        tauri::WindowEvent::Focused(focused) => {
            // Emit to frontend
            window.emit("window-focus", focused).unwrap();
        }
        _ => {}
    }
});
```

**File: `src/hooks/useWindowFocus.ts`**
```typescript
import { listen } from '@tauri-apps/api/event';

export function useWindowFocus() {
  const [isFocused, setIsFocused] = useState(true);

  useEffect(() => {
    const unlisten = listen<boolean>('window-focus', (e) => {
      setIsFocused(e.payload);
      document.documentElement.classList.toggle('window-unfocused', !e.payload);
    });
    return () => { unlisten.then(fn => fn()); };
  }, []);

  return isFocused;
}
```

**File: `src/index.css`**
```css
/* Dim colors when window loses focus */
.window-unfocused .tab-active {
  background-color: var(--pf-t--global--background--color--secondary--default);
}
.window-unfocused .sidebar-item-selected {
  background-color: #808080;
}
```

**Effort:** 45 min

---

## Files to Modify

| File | Changes |
|------|---------|
| `src-tauri/Cargo.toml` | Add `window-vibrancy`, `tauri-plugin-prevent-default` |
| `src-tauri/tauri.conf.json` | Add `transparent`, `titleBarStyle`, `hiddenTitle`, `macOSPrivateApi` |
| `src-tauri/src/lib.rs` | Native menu bar, vibrancy, prevent-default, window events |
| `src/index.css` | Native-feel CSS (selection, focus, drag regions, cursor) |
| `src/config/defaultKeybindings.json` | **New:** Default keyboard shortcuts |
| `src/config/keybindingsSchema.ts` | **New:** Keybinding types and key mapping |
| `src/hooks/useKeybindings.ts` | **New:** VSCode-style keybinding system |
| `src/hooks/useWindowFocus.ts` | **New:** Focus state management |
| `src/components/ContextMenu.tsx` | **New:** PatternFly-based context menu |
| `package.json` | Add `motion` |

---

## Implementation Order (Recommended)

1. **Phase 0: Native Menu Bar** - macOS-style app menu (critical for native feel)
2. **Phase 1: CSS Foundation** - Quick wins, no dependencies
3. **Phase 2: Disable Browser Behaviors** - Essential (no DevTools inspect, no Cmd+F)
4. **Phase 3: Window Vibrancy** - Visual impact, macOS blur
5. **Phase 4: Context Menus** - PatternFly Menu component (Notion-style)
6. **Phase 5: Keybindings** - VSCode-style configurable shortcuts
7. **Phase 6: Animations** - Motion library for spring physics
8. **Phase 7: Focus/Blur State** - Dim UI when window unfocused

---

## Known Limitations

1. **Vibrancy is macOS-only** - Windows/Linux will have solid background
2. **backdrop-filter bug in Tauri 2.2.5** - CSS blur may conflict with window transparency
3. **DevTools in dev mode** - Keep enabled for debugging, disable only in production

---

## Estimated Total Effort

| Phase | Time |
|-------|------|
| Phase 0: Native Menu | 1 hour |
| Phase 1: CSS | 30 min |
| Phase 2: Prevent Default | 15 min |
| Phase 3: Vibrancy | 45 min |
| Phase 4: Context Menus | 1.5 hours |
| Phase 5: Keybindings | 2 hours |
| Phase 6: Animations | 2 hours |
| Phase 7: Focus/Blur | 45 min |
| **Total** | **~9 hours** |

---

## Success Criteria

- [ ] Menu bar looks native macOS (HQ, File, Edit, View, Window, Help)
- [ ] No focus outlines on mouse click, only on Tab navigation
- [ ] Text not selectable on buttons, labels, headers
- [ ] Cmd+F, Cmd+P, right-click "Inspect" disabled in production
- [ ] DevTools accessible in dev mode only
- [ ] Window has translucent blur effect (macOS vibrancy)
- [ ] Right-click shows custom PatternFly context menu (Notion-style)
- [ ] Keyboard shortcuts configurable via JSON file
- [ ] Cmd+T/W/[/] work for tab management
- [ ] UI dims when window loses focus
- [ ] Animations feel "springy", not "tweeny"

---

## References

- [VSCode keybindings.json](https://code.visualstudio.com/docs/configure/keybindings)
- [PatternFly Menu Component](https://www.patternfly.org/components/menus/menu)
- [Tauri window-vibrancy](https://github.com/tauri-apps/window-vibrancy)
- [tauri-plugin-prevent-default](https://github.com/ferreira-tb/tauri-plugin-prevent-default)
- [Making Electron Apps Feel Native](https://getlotus.app/21-making-electron-apps-feel-native-on-mac)
- [Motion (Framer Motion)](https://motion.dev/)
