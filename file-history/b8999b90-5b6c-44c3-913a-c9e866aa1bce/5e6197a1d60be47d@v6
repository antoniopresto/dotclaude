# UX Competitive Intelligence: Documentação Profissional

## DIAGNÓSTICO: Por Que os Documentos Atuais Não Têm Valor

### Problemas Identificados

| Problema | Evidência | Impacto |
|----------|-----------|---------|
| **Screenshots de marketing, não produto** | signaturerail-home.png, tracsis-home.png | Designer não consegue extrair patterns |
| **Foco em business, não design** | SWOT, Market Gaps, Threat Assessment | Inútil para decisões de UI/UX |
| **Imagens decorativas** | Sem anotações, callouts, análise | Não são referência de design |
| **Estrutura de PM, não Designer** | Executive Summary, Recomendações de Negócio | Designer não sabe o que fazer |
| **Sem especificações** | Nenhum hex code, font size, spacing | Impossível replicar patterns bons |

### O Que Profissionais de UX Realmente Fazem

**Fonte:** [Maze - UX Competitive Analysis](https://maze.co/collections/ux-ui-design/ux-competitive-analysis/)
> "Competitive analysis in UX is a research method that involves systematically examining the user experiences offered by competing products."

**Fonte:** [LogRocket - Product Teardown](https://blog.logrocket.com/product-management/product-teardown-process-tools/)
> "A digital product teardown applies reverse-engineering mindset to software... Instead of deconstructing physical parts, we deconstruct the user experience."

**Fonte:** [Loop11 - UX Espionage](https://loop11.medium.com/competitive-benchmarking-the-art-of-ux-espionage-2d8d409ea4c9)
> "Competitive benchmarking is a foray into the world of espionage. Being able to see which elements of your competitor's website are working, and which are not."

---

## OBJETIVO REAL

Criar documentação de **UX Research** que permita a um designer:
1. **Ver** patterns de UI dos competidores
2. **Entender** flows de usuário que funcionam
3. **Extrair** design tokens (cores, tipografia, spacing)
4. **Decidir** o que copiar, adaptar ou evitar
5. **Implementar** melhorias no MMS-MFC

---

## ESTRUTURA DE DOCUMENTOS A CRIAR

```
docs/
├── ux-research/
│   ├── README.md                    # Índice e metodologia
│   ├── pattern-library.md           # UI Patterns extraídos
│   ├── flow-analysis.md             # User flows documentados
│   ├── competitor-teardowns/
│   │   ├── railnova-teardown.md     # Teardown detalhado (melhor UX)
│   │   └── signaturerail-teardown.md # Teardown (worst practices)
│   └── design-recommendations.md    # Síntese acionável
│
└── images/
    └── ux-research/                 # Screenshots com propósito
        ├── patterns/                # Componentes isolados
        ├── flows/                   # Sequências de telas
        └── teardowns/               # Análises anotadas
```

---

## PARTE A: Metodologia de Espionagem UX

### Fontes de Referência Profissional

| Recurso | O Que Extrair | Link |
|---------|---------------|------|
| **Mobbin** | UI patterns de apps reais | [mobbin.com](https://mobbin.com) |
| **Page Flows** | User flow videos anotados | [pageflows.com](https://pageflows.com) |
| **Refero** | 30K+ screenshots organizados | [refero.design](https://refero.design) |
| **Nicely Done** | 50K+ web app screenshots | [nicelydone.club](https://nicelydone.club) |
| **Railnova Help** | Screenshots reais de produto railway | [help.railnova.eu](https://help.railnova.eu) |

### Anti-Patterns a Evitar (Sênior Advice)

**Fonte:** [Eleken - Competitive Analysis](https://www.eleken.co/blog-posts/competitive-analysis-in-ux-design-process-methods-and-concerns)

| Anti-Pattern | Consequência | Como Evitar |
|--------------|--------------|-------------|
| Listas infinitas sem insights | Paralisia de análise | Definir 3-5 patterns-chave ANTES |
| Copiar ao invés de aprender | Design sem propósito | Documentar POR QUE funciona |
| Só olhar estética | Perder usabilidade | Aplicar heurísticas Nielsen |
| Análise única (one-time) | Docs obsoletos | Estrutura para updates |
| Ignorar competidores indiretos | Blind spots | Incluir alternativas não-óbvias |

### Heurísticas de Nielsen (Aplicar com Evidência)

| # | Heurística | Pergunta para cada tela |
|---|------------|-------------------------|
| 1 | Visibilidade do status | O usuário sabe onde está e o que está acontecendo? |
| 2 | Match sistema/mundo real | Usa terminologia de railway que operadores reconhecem? |
| 3 | Controle do usuário | Tem undo, escape, cancel visíveis? |
| 4 | Consistência | Mesmos patterns em todas as telas? |
| 5 | Prevenção de erros | Design evita erros antes que aconteçam? |
| 6 | Reconhecimento > memória | Informações visíveis ou precisa lembrar? |
| 7 | Flexibilidade | Atalhos para experts? Simplificação para novatos? |
| 8 | Design minimalista | Só informação necessária, sem ruído? |
| 9 | Recuperação de erros | Mensagens claras e ações de correção? |
| 10 | Help | Documentação acessível quando necessário? |

---

## PARTE B: Fases de Execução

### Fase 1: Preparação e Limpeza
**Objetivo:** Arquivar docs antigos, criar estrutura nova
**Tempo:** 15 min

**Tarefas:**
- [ ] Mover docs existentes para `docs/_archive/` (não deletar, manter histórico)
- [ ] Criar estrutura de pastas `docs/ux-research/`
- [ ] Criar estrutura de imagens `docs/images/ux-research/`

---

### Fase 2: Coleta de Screenshots de Produto Real
**Objetivo:** Capturar interfaces REAIS, não marketing
**Tempo:** 45 min

**Fontes Prioritárias:**
1. **Railnova Help Center** - Tem screenshots de produto real
   - Operational Dashboard
   - Fleet Availability (Gantt)
   - Map view
   - Maintenance planning

2. **SignatureRail Videos** - Frame extraction de demos
   - Fleet Manager Gantt
   - TrainPlan tables

**Critério de Qualidade:**
- [ ] Screenshot mostra interface de PRODUTO, não marketing
- [ ] Componentes de UI identificáveis
- [ ] Resolução suficiente para análise

---

### Fase 3: Pattern Library Extraction
**Objetivo:** Documentar componentes de UI encontrados
**Tempo:** 60 min

**Patterns a Documentar:**

| Pattern | O Que Capturar | Aplicação MMS-MFC |
|---------|----------------|-------------------|
| **Dashboard Cards** | Layout, métricas mostradas, cores de status | DashboardKPIs |
| **Data Tables** | Colunas, sorting, filtering, pagination | Fleet list, Schedule |
| **Gantt Charts** | Eixos, cores, interações, zoom | MaintenanceGantt |
| **Maps** | Markers, overlays, filtros, popups | FleetMap |
| **Navigation** | Sidebar vs top, hierarquia, estados | Navigation component |
| **Status Indicators** | Cores, ícones, badges, progresso | Todos os lugares |
| **Forms** | Inputs, validation, layout | Allocation forms |
| **Filters** | Dropdowns, chips, search, date pickers | Todas as páginas |

**Template por Pattern:**
```markdown
## [Nome do Pattern]

### Exemplo: [Competidor]
![Screenshot](path/to/image.png)

### Análise
- **O que funciona:** [...]
- **O que não funciona:** [...]
- **Design tokens:** Cor X (#hex), Spacing Y (px)

### Recomendação para MMS-MFC
- **Copiar:** [...]
- **Adaptar:** [...]
- **Evitar:** [...]
```

---

### Fase 4: Flow Analysis
**Objetivo:** Documentar user journeys completos
**Tempo:** 45 min

**Flows Prioritários:**

| Flow | Por Que Importa | Competidor Referência |
|------|-----------------|----------------------|
| **Ver status da frota** | Core use case | Railnova Operational Dashboard |
| **Identificar problema** | Valor principal | Railnova Alerts + Map |
| **Planejar manutenção** | Differentiator | Railnova Fleet Availability |
| **Alocar recurso** | Nossa página Allocation | SignatureRail Assign Uncovered |

**Template por Flow:**
```markdown
## Flow: [Nome]

### Passos
1. [Screenshot 1] - Usuário vê X
2. [Screenshot 2] - Usuário clica Y
3. [Screenshot 3] - Sistema mostra Z

### Análise UX
- **Pontos fortes:** [...]
- **Pontos fracos:** [...]
- **Heurísticas aplicadas:** [1, 4, 6]

### Aplicação MMS-MFC
- Nosso flow atual: [link para página]
- Gaps identificados: [...]
- Melhorias propostas: [...]
```

---

### Fase 5: Design Recommendations
**Objetivo:** Síntese acionável para designers/devs
**Tempo:** 30 min

**Estrutura do Documento:**

```markdown
# Design Recommendations for MMS-MFC

## 1. Quick Wins (Implementar Agora)
| Mudança | Evidência | Esforço | Impacto |
|---------|-----------|---------|---------|

## 2. Patterns a Adotar
### Dashboard
- [Pattern específico com screenshot]

### Tables
- [Pattern específico com screenshot]

## 3. Anti-Patterns a Evitar
| O Que Evitar | Por Quê | Alternativa |
|--------------|---------|-------------|

## 4. Design Tokens Sugeridos
### Cores de Status
- Operational: #xxx
- Degraded: #xxx
- Immobilized: #xxx

### Tipografia
- [...]
```

---

### Fase 6: BMAD UX Workflow
**Objetivo:** Invocar workflow para implementação
**Tempo:** Conforme workflow

Após documentação completa, invocar:
```
/create-ux-design
```

Com input dos documentos criados.

---

## PARTE C: Critérios de Qualidade

### Checklist Final

| Critério | Verificação |
|----------|-------------|
| Screenshots são de PRODUTO, não marketing | [ ] |
| Cada imagem tem propósito documentado | [ ] |
| Patterns extraídos são acionáveis | [ ] |
| Flows documentam jornadas completas | [ ] |
| Recomendações são específicas | [ ] |
| Designer consegue usar para implementar | [ ] |
| Heurísticas aplicadas com evidência | [ ] |

### Teste de Utilidade
> "Se um designer junior pegar esse documento, consegue melhorar o MMS-MFC sem perguntar nada?"

Se não → documento precisa mais detalhes.

---

## PARTE D: Arquivos a Criar

| Arquivo | Propósito | Prioridade |
|---------|-----------|------------|
| `docs/ux-research/README.md` | Índice e metodologia | P0 |
| `docs/ux-research/pattern-library.md` | Componentes extraídos | P0 |
| `docs/ux-research/flow-analysis.md` | User journeys | P1 |
| `docs/ux-research/competitor-teardowns/railnova.md` | Best practices | P1 |
| `docs/ux-research/design-recommendations.md` | Síntese acionável | P0 |

---

## Arquivos a Arquivar (Não Deletar)

```
docs/competitive-analysis-signaturerail.md → docs/_archive/
docs/competitive-landscape-railway-software.md → docs/_archive/
docs/images/competitive-research/* → docs/_archive/images/
```

---

## FONTES DA PESQUISA

### Metodologia UX Research
- [Maze - UX Competitive Analysis](https://maze.co/collections/ux-ui-design/ux-competitive-analysis/)
- [UXPin - Competitive Analysis for UX](https://www.uxpin.com/studio/blog/competitive-analysis-for-ux/)
- [Baymard - UX Competitive Analysis](https://baymard.com/learn/competitive-analysis-ux)

### Product Teardown
- [LogRocket - Product Teardown](https://blog.logrocket.com/product-management/product-teardown-process-tools/)
- [GHB Intellect - Teardown Analysis](https://ghbintellect.com/competitive-teardown-analysis/)

### Pattern Libraries
- [Mobbin](https://mobbin.com) - UI patterns
- [Page Flows](https://pageflows.com) - User flow videos
- [UXPin - Pattern Library Guide](https://www.uxpin.com/studio/blog/how-to-build-a-scalable-design-pattern-library/)

### Anti-Patterns
- [Eleken - Common Mistakes](https://www.eleken.co/blog-posts/competitive-analysis-in-ux-design-process-methods-and-concerns)
- [Signal Insights - CI Mistakes](https://signalinsights.io/blog/seven-common-competitive-analysis-mistakes/)
- [Charisol - Mistakes to Avoid](https://charisol.io/8-mistakes-to-avoid-in-competitor-analysis/)

### Report Structure
- [Looppanel - UX Research Report](https://www.looppanel.com/blog/ux-research-report)
- [Dovetail - Report Structure](https://dovetail.com/blog/writing-format-ux-research-report/)
- [User Interviews - Templates](https://www.userinterviews.com/ux-research-field-guide-module/research-deliverables-reporting)
| Fato observado | `[FATO]` - vi na tela/screenshot |
| Inferência | `[INFERÊNCIA]` - deduzi de evidências |
| Especulação | `[ESPECULAÇÃO]` - hipótese sem evidência direta |

- Confiança proporcional à evidência
- "Não encontrei" > inventar
- Citar fonte: URL exata, timestamp de vídeo, nome do screenshot

### 2. Anti-patterns a Evitar
| Anti-pattern | Como Evitar |
|--------------|-------------|
| Lista infinita sem insights | Definir critérios ANTES de coletar |
| Copiar cegamente | Avaliar se funcionalidade é boa ou ruim |
| Over-research | Foco em SignatureRail apenas |
| Dados sem ação | Cada finding tem "so what?" |
| Literalismo processual | Se passo não gera valor, pular |
| Screenshot decorativo | Cada imagem tem propósito documentado |

### 3. Checkpoints de Qualidade (executar ao fim de cada fase)
```
□ "Isso seria útil para decisão de produto?"
□ "Estou coletando dados ou gerando insights?"
□ "O que estou perdendo?" (unknown unknowns)
□ "Cada claim tem fonte citada?"
```

---

## PARTE B: Fases de Execução

### Fase 1: Reconhecimento (≤15 min)
**Objetivo:** Mapear estrutura antes de mergulhar
**Thinking level:** `think`

**Tarefas:**
- [ ] Navegar homepage, capturar screenshot
- [ ] Verificar robots.txt (permissões de crawling)
- [ ] Identificar menu principal e seções
- [ ] Mapear URLs de interesse:
  - [ ] Produtos (quais existem?)
  - [ ] Treinamento/Vídeos (onde estão?)
  - [ ] About/Company (história, equipe)
  - [ ] Resources/Blog (artigos técnicos?)
  - [ ] Pricing (modelo de negócio?)
  - [ ] Contact (localização, tamanho?)

**Output:** Sitemap em `claude-progress.txt`

**Ferramentas:** Playwright (navegação), WebFetch (texto)

**Checkpoint:**
- Tenho visão geral completa?
- Sei exatamente onde estão os conteúdos de valor?
- Priorizei o que explorar primeiro?

---

### Fase 2: Análise de Produtos
**Objetivo:** Entender oferta de valor do competidor
**Thinking level:** `think`

**Para CADA produto identificado:**
- [ ] Nome oficial e tagline
- [ ] Proposta de valor declarada (quote exata)
- [ ] Features listadas (com evidência)
- [ ] Público-alvo aparente
- [ ] Screenshots da interface (se disponível)
- [ ] Modelo de deployment (SaaS? On-premise?)
- [ ] **So what?** Comparação implícita com MMS-MFC

**Produtos esperados (confirmar):**
- ResourcePlan (timetable planning)
- TrainPlan (resource planning)
- Fleet Manager (on-the-day operations)

**Ferramentas:** Playwright (screenshots), WebFetch (descrições)

**Checkpoint:**
- Entendi o que cada produto faz de verdade?
- Identifiquei overlaps com nosso MMS-MFC?

---

### Fase 3: Extração de Conteúdo de Treinamento
**Objetivo:** Capturar conhecimento dos vídeos e materiais educacionais
**Thinking level:** `ultrathink`

**IMPORTANTE: Vídeos estão em Wistia (sem transcrição automática)**

**Estratégia de 3 camadas:**

**Camada 1: Conteúdo Textual (fazer primeiro)**
- [ ] WebFetch em CADA página de vídeo → extrair descrições
- [ ] Buscar seção Resources/Documentation no site
- [ ] Procurar PDFs, user guides, help center
- [ ] Extrair texto de artigos relacionados

**Camada 2: Multi-Frame Video Analysis (para vídeos prioritários)**
Para cada vídeo importante:
1. Reproduzir vídeo
2. Capturar screenshot a cada 10-15 segundos
3. Pausar em momentos-chave de UI
4. Analisar CONJUNTO de frames para entender workflow completo

**Camada 3: Síntese por Vídeo**
| Campo | O que capturar |
|-------|----------------|
| Título | Nome exato |
| URL | Link direto |
| Duração | Tempo total |
| Descrição textual | Do WebFetch da página |
| Frames capturados | Lista de screenshots |
| Workflow demonstrado | Passo-a-passo observado nos frames |
| Features identificadas | Com evidência visual |
| UI Patterns | Componentes, layouts, cores |
| Gaps/Problemas | O que parece ruim ou faltando |
| Insight MMS-MFC | "So what?" acionável |

**Vídeos prioritários (foco em Fleet Manager - mais relevante para MMS-MFC):**
1. Fleet Manager demos (On-the-Day operations)
2. TrainPlan - Assign Uncovered Trains (similar ao nosso allocation)
3. TrainPlan - Vehicle Diagrams (similar ao nosso schedule)

**Rate limiting:** Pausar entre requisições

**Ferramentas:**
- WebFetch (descrições textuais)
- Playwright (reproduzir vídeos, capturar frames)
- Read (analisar screenshots capturados)

**Checkpoint:**
- Extraí conteúdo textual de TODAS as páginas de vídeo?
- Para vídeos-chave, tenho frames suficientes para entender o workflow?
- Cada vídeo gerou insight acionável para MMS-MFC?

---

### Fase 4: Análise UX/Design
**Objetivo:** Avaliar com heurísticas, não opinião
**Thinking level:** `think hard`

**Heurísticas de Nielsen (aplicar com evidência):**
| Heurística | Pergunta | Evidência |
|------------|----------|-----------|
| Visibilidade do status | Sistema informa o que está acontecendo? | Screenshot X |
| Match sistema/mundo real | Usa linguagem do usuário (railway)? | Exemplo Y |
| Controle do usuário | Permite undo/escape fácil? | Observação Z |
| Consistência | Mesmos padrões em todo produto? | Comparação A vs B |
| Prevenção de erros | Evita que usuário erre? | Interface W |
| Reconhecimento > memória | Informações visíveis vs. ter que lembrar? | |
| Flexibilidade/eficiência | Atalhos para usuários experientes? | |
| Design minimalista | Só informação relevante? | |
| Recuperação de erros | Mensagens de erro claras? | |
| Help/documentação | Fácil encontrar ajuda? | |

**Padrões de Design a Documentar:**
- [ ] Paleta de cores (hex codes se possível)
- [ ] Tipografia (fontes, hierarquia)
- [ ] Componentes recorrentes (cards, tabelas, gráficos)
- [ ] Navegação (estrutura, breadcrumbs)
- [ ] Dashboards (layout, KPIs mostrados)
- [ ] Data visualization (tipos de gráficos usados)

**Ferramentas:** Playwright screenshots, análise visual

**Checkpoint:**
- Minhas avaliações são baseadas em heurísticas ou preferência pessoal?
- Cada ponto forte/fraco tem evidência anexa?

---

### Fase 5: Conteúdo Técnico e Artigos
**Objetivo:** Extrair conhecimento técnico e tendências
**Thinking level:** `think`

**Se existir blog/resources:**
- [ ] Listar artigos relevantes (últimos 12 meses)
- [ ] Identificar temas recorrentes
- [ ] Extrair insights técnicos (não copiar texto)
- [ ] Notar terminologia específica do domínio

**Informações técnicas a buscar:**
- [ ] Arquitetura mencionada (cloud, on-prem, híbrido)
- [ ] Integrações disponíveis (APIs, conectores)
- [ ] Standards suportados (GTFS, NeTEx, etc.)
- [ ] Stack tecnológico (se mencionado)

**Checkpoint:**
- Encontrei informação técnica útil ou só marketing?

---

### Fase 6: Síntese Estratégica
**Objetivo:** Transformar dados em insights acionáveis
**Thinking level:** `ultrathink`

**Framework de análise:**
```
Fato Observado → Implicação → Ação Sugerida para MMS-MFC
```

**SWOT do Competidor:**
| | Positivo | Negativo |
|---|----------|----------|
| Interno | Strengths (forças) | Weaknesses (fraquezas) |
| Externo | Opportunities (oportunidades para nós) | Threats (ameaças para nós) |

**Gaps a explorar:**
- O que SignatureRail NÃO faz que MMS-MFC pode fazer?
- Onde a UX deles é fraca?
- Que mercado eles não atendem bem?

**Features a considerar:**
- O que eles fazem bem que devemos igualar?
- O que podemos fazer melhor?

**Erros a evitar:**
- O que eles fazem mal que devemos evitar?

---

## PARTE C: Estrutura do Documento Final

```markdown
# SignatureRail - Competitive Intelligence Report
**Generated:** [DATA]
**Analyst:** Claude (MMS-MFC Research)

## Executive Summary
- 5 bullets máximo
- Principais insights acionáveis
- Recomendação primária para MMS-MFC

## Company Overview
- Localização, tamanho estimado, história
- Posicionamento de mercado
- Clientes mencionados

## Product Portfolio

### Product 1: [Nome]
- Proposta de valor: "[quote exata]"
- Features principais (com screenshots)
- Público-alvo
- **Comparação MMS-MFC:** [overlap/diferencial]

### Product 2: [Nome]
[mesma estrutura]

## Training Content Analysis
| Vídeo | Duração | Features Demonstradas | Insight para MMS-MFC |
|-------|---------|----------------------|---------------------|

## UX/Design Evaluation
### Padrões Identificados
[screenshots anotados com propósito]

### Heurísticas de Nielsen
[avaliação com evidência]

### SWOT Visual
[tabela SWOT]

## Technical Capabilities
- Arquitetura (se conhecida)
- Integrações
- Standards

## Strategic Opportunities for MMS-MFC
### Gaps to Exploit
[com evidência]

### Features to Consider
[com rationale]

### Mistakes to Avoid
[com exemplo]

## Sources
| URL | Data de Acesso | Conteúdo |
|-----|----------------|----------|
```

---

## PARTE D: Integração Harness

### Progress Tracking
Atualizar `claude-progress.txt` após CADA fase:
```
[TIMESTAMP] SignatureRail Research - Fase X: STATUS
  Completado:
    - item 1
    - item 2
  Pendente:
    - item 3
  Bloqueios: [se houver]
  Decisões: [se tomadas]
  Insights: [principais descobertas]
```

### Gestão de Bloqueios
1. Documentar problema específico
2. Tentar alternativa (outro método, outra fonte)
3. Se insolúvel: documentar e continuar
4. **NÃO parar por dúvida resolvível**

### Screenshots
Salvar em `.playwright-mcp/` com nomes descritivos:
- `signaturerail-homepage.png`
- `signaturerail-trainplan-dashboard.png`
- `signaturerail-video-frame-[feature].png`

---

## PARTE E: Critérios de Conclusão

| Critério | Verificação |
|----------|-------------|
| Todas páginas principais documentadas | [ ] |
| Todos produtos analisados | [ ] |
| Vídeos prioritários extraídos | [ ] |
| Screenshots com propósito | [ ] |
| Heurísticas aplicadas | [ ] |
| SWOT completo | [ ] |
| Oportunidades para MMS-MFC | [ ] |
| Cada claim tem fonte | [ ] |
| Documento útil para PM | [ ] |
| claude-progress.txt atualizado | [ ] |

---

## PARTE F: Proibições Explícitas

❌ Inventar informação não encontrada
❌ Pular fase sem checkpoint
❌ Auto-aprovar sem revisar
❌ Lista de dados sem insights
❌ Copiar design sem avaliar qualidade
❌ Screenshots sem anotação/propósito
❌ Formatação decorativa sem valor
❌ Parar por dúvida resolvível
❌ Over-research em tangentes
