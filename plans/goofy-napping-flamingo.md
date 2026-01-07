# F018: UX & Design Overhaul - PatternFly-First Approach

## Executive Summary

Refatorar completamente o HQ para usar **apenas componentes e classes PatternFly**, eliminando todo CSS inline e customizado. Isso garante consistência, manutenibilidade e aderência ao Design System.

---

## Audit Results - Technical Debt Found

### CSS Inline (76+ instâncias):
| Arquivo | Instâncias |
|---------|------------|
| ScreenshotViewer.tsx | 9 |
| ProgressCard.tsx | 8 |
| KanbanBoard.tsx | 8 |
| Settings.tsx | 8 |
| TaskExecutionModal.tsx | 7 |
| ProjectSelector.tsx | 6 |
| TabBar.tsx | 6 |
| KanbanCard.tsx | 5 |
| App.tsx | 5 |
| TerminalPanel.tsx | 5 |
| ContextMenu.tsx | 4 |
| LogPanel.tsx | 3 |
| TaskModal.tsx | 1 |
| **AppLayout.tsx** | **DELETE (custom classes)** |

### Files to Delete:
- `src/components/AppLayout.tsx` - Uses custom CSS classes, violates Design System

### Custom CSS to Remove:
- `src/index.css` - Manter apenas reset mínimo se necessário

---

## Implementation Plan

### Phase 1: Update CLAUDE.md with Design System Rules

Add enforcement rules to CLAUDE.md:

```markdown
## PatternFly Design System (MANDATORY)

### CRITICAL RULES:
1. **NEVER use inline styles** (`style={{...}}`) - Use PatternFly props
2. **NEVER create custom CSS classes** - Use PatternFly layout components
3. **ALWAYS use PatternFly spacing props** - `spaceItems`, `gap`, `hasGutter`
4. **ALWAYS use PatternFly layout components** - Flex, Stack, Split, Grid

### PatternFly Component Mapping:
| Need | Use |
|------|-----|
| Spacing | `spaceItems`, `gap`, `hasGutter` props |
| Margins | Flex `spacer` prop or Stack/Split with `hasGutter` |
| Horizontal layout | `<Split>` or `<Flex direction="row">` |
| Vertical layout | `<Stack>` or `<Flex direction="column">` |
| Colors | PatternFly Label `color` prop, Alert variants |
| Typography | `<Content component="p/h1/small">` |
| Centering | Flex `alignItems="center"` `justifyContent="center"` |

### References:
- Layout: https://www.patternfly.org/layouts/flex
- Spacing: https://www.patternfly.org/design-foundations/spacers
- Page: https://www.patternfly.org/components/page
- Drawer: https://www.patternfly.org/components/drawer
```

---

### Phase 2: Refactor Layout Architecture (No Custom CSS)

Use PatternFly native components:

```tsx
// CORRECT - PatternFly Page with Sidebar
<Page
  masthead={masthead}
  sidebar={
    <PageSidebar isSidebarOpen={sidebarOpen}>
      <PageSidebarBody>
        <Nav aria-label="Projects">
          <NavList>...</NavList>
        </Nav>
      </PageSidebarBody>
    </PageSidebar>
  }
  isManagedSidebar
>
  <PageSection>Content</PageSection>
</Page>
```

Bottom Panel using Drawer:
```tsx
<Drawer isExpanded={showPanel} position="bottom">
  <DrawerContent panelContent={<DrawerPanelContent>Logs</DrawerPanelContent>}>
    <DrawerContentBody>Main content</DrawerContentBody>
  </DrawerContent>
</Drawer>
```

---

### Phase 3: Refactor Each Component (Remove Inline CSS)

For each file, replace inline styles with PatternFly equivalents:

#### Example Transformations:

```tsx
// BEFORE (WRONG)
<Alert style={{ marginBottom: 16 }}>

// AFTER (CORRECT)
<Stack hasGutter>
  <StackItem><Alert>...</Alert></StackItem>
  <StackItem>Next content</StackItem>
</Stack>
```

```tsx
// BEFORE (WRONG)
<div style={{ marginTop: '16px', display: 'flex', gap: '8px' }}>

// AFTER (CORRECT)
<Flex spaceItems={{ default: 'spaceItemsSm' }}>
```

```tsx
// BEFORE (WRONG)
<Spinner size="md" style={{ marginLeft: 8 }} />

// AFTER (CORRECT)
<Split hasGutter>
  <SplitItem>Content</SplitItem>
  <SplitItem><Spinner size="md" /></SplitItem>
</Split>
```

---

### Phase 4: Files to Modify (Priority Order)

1. **CLAUDE.md** - Add Design System rules
2. **src/index.css** - Remove custom CSS (keep only necessary resets)
3. **Delete src/components/AppLayout.tsx** - Custom classes violate rules
4. **src/App.tsx** - Use Page, PageSidebar, Drawer
5. **src/components/KanbanBoard.tsx** - Use Flex, Stack
6. **src/components/KanbanCard.tsx** - Use Card props, Flex
7. **src/components/ProgressCard.tsx** - Use Stack, Split
8. **src/components/ProjectSelector.tsx** - Use Stack, Flex
9. **src/components/ScreenshotViewer.tsx** - Use Gallery, Flex
10. **src/components/TaskExecutionModal.tsx** - Use Stack, Flex
11. **src/components/TabBar.tsx** - Use Tabs component properly
12. **src/components/Settings.tsx** - Use Form, FormGroup, Stack
13. **src/components/TerminalPanel.tsx** - Use Card, Stack
14. **src/components/LogPanel.tsx** - Use Toolbar props
15. **src/components/ContextMenu.tsx** - Use Menu component
16. **src/components/TaskModal.tsx** - Use Stack

---

### Phase 5: Add Technical Debt Task to features.json

Add F019:
```json
{
  "id": "F019",
  "description": "Technical Debt Cleanup - Remove all inline CSS, custom classes, mocks, and FIXMEs",
  "category": "core",
  "priority": "critical",
  "status": "backlog",
  "passes": false,
  "steps": [
    "Audit all files for inline styles (style={{...}})",
    "Replace inline styles with PatternFly layout components",
    "Remove src/components/AppLayout.tsx (uses custom classes)",
    "Clean up src/index.css (remove custom CSS)",
    "Search and remove any FIXME, TODO, HACK, XXX comments",
    "Search and remove any mock data or temporary code",
    "Visual test all components with Playwright MCP",
    "Update CLAUDE.md with PatternFly enforcement rules"
  ]
}
```

---

## PatternFly Component Reference

### Layout Components:
- **Page** - Main app shell with masthead, sidebar, sections
- **PageSidebar** - Left navigation panel
- **PageSection** - Content sections with padding
- **Drawer** - Slide-out panel (bottom for logs/terminal)
- **Flex** - Flexbox layout with spacing props
- **Stack** - Vertical layout with hasGutter
- **Split** - Horizontal layout with hasGutter
- **Grid/GridItem** - CSS Grid layout

### Spacing Props:
- `hasGutter` - Add gap between children
- `spaceItems` - Control spacing (xs, sm, md, lg, xl)
- `gap` - CSS gap property
- `padding` - Section padding by breakpoint

### Key References:
- https://www.patternfly.org/layouts/flex
- https://www.patternfly.org/layouts/stack
- https://www.patternfly.org/layouts/split
- https://www.patternfly.org/components/page
- https://www.patternfly.org/components/drawer
- https://www.patternfly.org/design-foundations/spacers

---

## Success Criteria

- [ ] Zero inline styles (`style={{...}}`) in codebase
- [ ] Zero custom CSS classes in components
- [ ] index.css contains only necessary resets
- [ ] All layouts use PatternFly Page, Flex, Stack, Split, Drawer
- [ ] CLAUDE.md enforces PatternFly-first approach
- [ ] Visual tests pass with Playwright MCP
- [ ] No FIXMEs, TODOs, mocks, or temporary code
