# Plan: Expand progress.txt with SDUI spike task breakdown

## Context

The spike (SPMAIS-34653) deliverable is a **demonstration of the SDUI rendering architecture** proposed in `.claude/rfc-conteudo-dinamico.txt`. The demo runs in Storybook (independent of the SuperApp) and shows voucher screens rendered from JSON payloads through an SDUI engine.

## File to modify

- `.claude/progress.txt` — replace current content with expanded task list below

## Expanded task list

```
# SP_0001.0 — Setup Storybook
Configure Storybook so this MFE can render screens independently of the SuperApp.

Context:
- This is a React Native MFE (package.json: react 18.2.0, react-native 0.73.6)
- The design system (@semparar/design-system-app ^3.39.15) already has Storybook
  configured — its setup can be used as reference if the executing agent needs it
- Babel aliases: ~ → ./src/ (babel.config.js line 27)
- TS alias: ~/store → ./@types/store.d.ts (tsconfig.json line 11) — this is a
  module augmentation for the SuperApp's Zustand store, needs mocking
- DS components depend on design tokens — may need a ThemeProvider or similar

Deliverable: `npm run storybook` opens a browser with a smoke test story that
renders at least one DS component (e.g., Button or Text from @semparar/design-system-app).

---

# SP_0001.1 — Validate DS components in Storybook
Prove that the design system components actually used in voucher screens render
correctly in the Storybook web context.

Context:
- The voucher screens use these DS components: Text, Button, Box, InputBox,
  Alert, Icon, ListTextIcon, SeparatorHorizontal, BackDropBottom, Loading
- See existing usage in:
  - src/screens/InvoiceCashbackPoints/view.tsx (form with inputs, balance, button)
  - src/screens/InvoiceCashbackSummary/view.tsx (review, success, error states)
  - src/screens/InvoiceCashbackOnboarding/index.tsx (list items with icons)
- Some components may not render in web — document which ones work and which don't

Deliverable: A story page rendering each DS component listed above. Annotate any
that fail or need workarounds.

---

# SP_0002.0 — SDUI Core: Types & Interfaces
Define the TypeScript type system for the SDUI architecture described in
.claude/rfc-conteudo-dinamico.txt (sections 3.1–3.5).

Context:
- Screen structure: { id, context, header, body[], footer } (RFC section 3.1)
- Components: { type, props } (RFC section 3.2)
- Rich text: { type: "rich_text", children: [nodes] } (RFC section 3.3)
- Context interpolation: {{var}} pattern (RFC section 3.4)
- Conditionals: JSON Logic subset (RFC section 3.5)
- Follow project conventions: .claude/STYLE_GUIDE.md (services architecture,
  models in Models/ folders)

Deliverable: Type definitions in src/services/sdui/models/ that contract the
entire SDUI system (Screen, Component, Context, RichText, ComponentRegistry).

---

# SP_0002.1 — SDUI Core: Interpolation Parser
Implement the {{var}} replacement engine from RFC section 3.4.

Context:
- Must resolve nested paths: {{product.name}}, {{balance.pointsFormatted}}
- Must deep-walk an object interpolating all string values in props
- Missing values should resolve gracefully (empty string, not crash)
- Existing interpolation example in RFC:
  "Voucher para {{product.name}}" + context.product.name = "Abastecimento"
  → "Voucher para Abastecimento"
- Types from SP_0002.0 should be used

Deliverable: Interpolation utility with unit tests.

---

# SP_0002.2 — SDUI Core: Component Registry & Screen Renderer
Build the rendering engine that turns a JSON screen definition into React
components. This is the core of the SDUI architecture (RFC sections 3.1–3.2).

Context:
- Registry maps string type → React component (RFC section 3.2 "Componentes")
- Renderer receives SDUIScreen JSON, iterates body[], renders each via registry
- Must apply interpolation (SP_0002.1) to all string props using screen context
- Unknown types should render a visible fallback (not crash)
- Types from SP_0002.0, interpolation from SP_0002.1

Deliverable: A <ScreenRenderer screen={json} /> component that renders a
screen definition from JSON.

---

# SP_0002.3 — SDUI Component Adapters
Create adapters that bridge SDUI component types to actual DS components.

Context:
- Each adapter maps SDUI props to @semparar/design-system-app component props
- Required adapters based on voucher screen analysis (TASK.pdf + existing screens):

  | SDUI type        | DS component(s)           | Used in                    |
  |------------------|---------------------------|----------------------------|
  | heading          | Text (headingMDL)         | Form title, Review title   |
  | text             | Text (configurable)       | Labels, descriptions       |
  | balance_display  | Box + Text                | "Pontos disponíveis: X"   |
  | points_input     | InputBox                  | Points/reais fields        |
  | button           | Button                    | CTA buttons                |
  | link             | Text (pressable)          | "Exibir regras de uso"     |
  | alert            | Alert                     | Info boxes in summary      |
  | list_text_icon   | ListTextIcon              | Onboarding items, rules    |
  | separator        | SeparatorHorizontal       | Between fields             |
  | icon_text_row    | Box + Icon + Text         | Regras de uso bullet items |
  | section_heading  | Text (subtitleXXL)        | Regras section titles      |

- Register all in the default registry from SP_0002.2
- DS component validation from SP_0001.1 may affect which adapters are viable

Deliverable: All voucher-relevant adapters registered in the component registry.

---

# SP_0002.4 — Mock JSON Payloads
Create realistic JSON payloads for the voucher screens described in TASK.pdf.

Context:
- 4 screens need payloads (see TASK.pdf pages 2–4 for visual reference):
  1. Voucher form (points/reais input) — reference: InvoiceCashbackPoints/view.tsx
  2. Voucher summary (review before confirm) — reference: InvoiceCashbackSummary/view.tsx lines 47-151
  3. Voucher conclusion (success) — reference: InvoiceCashbackSummary/view.tsx lines 154-203
  4. Regras de uso (rules) — reference: TASK.pdf page 4 screenshot
- Product codes (src/screens/Points/data/index.ts lines 62-70):
  206 = Abastecimento, 205 = Estacionamento, 207 = Seguro Auto, 208 = IPVA
- Text differences per product visible in TASK.pdf page 2:
  - Cashback: "Defina quanto cashback quer na sua fatura"
  - Voucher: "Defina o desconto para seu abastecimento"
  - Cashback: "Cashback aplicado" / Voucher: "O voucher foi criado"
  - Cashback: "Confirmar desconto" / Voucher: "Criar voucher"
- Static content (labels, titles, rules) goes in JSON. Dynamic data (balance,
  points) comes from context — not hardcoded in the payload.
- Include at least 2 product variants (Abastecimento + Estacionamento) to prove
  the same renderer handles different products via different JSON.

Deliverable: JSON payloads for 4 screens × 2 products.

---

# SP_0002.5 — Demo Stories: SDUI Rendering
Final demonstration — render all voucher screens from JSON through the SDUI engine
in Storybook.

Context:
- Uses: ScreenRenderer (SP_0002.2), adapters (SP_0002.3), payloads (SP_0002.4)
- Each story feeds a mock JSON payload into <ScreenRenderer />
- Key demonstration: switching product context (Abastecimento → Estacionamento)
  changes the rendered screen WITHOUT changing any code — only JSON differs
- This is the spike's central proof: same code, different JSON, different screens

Deliverable: Storybook stories showing all 4 voucher screens rendered from JSON,
with product variant toggle proving reusability. This is the spike's final output.
```
