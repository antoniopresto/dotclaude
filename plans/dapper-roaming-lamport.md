# Plano: Stack de LLMs Locais + Anthropic Harness para Software Ferroviário

## Resumo Executivo

**Objetivo**: Configurar stack de modelos LLM locais via Ollama para orquestrar agentes especializados que delegam tarefas complexas ao Claude Opus 4.5, usando o padrão Anthropic Harness para persistência entre sessões.

**Hardware**: MacBook Pro M2 Pro (12 cores, 200 GB/s bandwidth, 16GB RAM unificada)

**Prioridade**: QUALIDADE > Velocidade

**Problema que resolve**: Perda de contexto e alucinações em sessões longas do Claude Code.

---

## 1. Modelos Recomendados para Ollama

### Stack Principal (Foco em Qualidade)

| Modelo | Uso | RAM | Tokens/s (M2 Pro) | Quantização |
|--------|-----|-----|-------------------|-------------|
| **deepseek-r1:14b** | Raciocínio complexo, meta-prompting | ~10GB | 15-20 | Q4_K_M |
| **deepseek-r1:8b** | Raciocínio diário, análise | ~6GB | 25-35 | Q5_K_M |
| **phi4-mini-reasoning** | Roteamento, triagem rápida | ~2.5GB | 45-55 | Q4_K_M |
| **qwen2.5-coder:7b** | Code review, debugging | ~5GB | 25-35 | Q4_K_M |

> **Nota**: Valores de tokens/s são estimativas baseadas em benchmarks públicos. Performance real pode variar ±20% dependendo da carga do sistema e tamanho do contexto.

### Alternativas (Fallback)

| Se indisponível... | Usar alternativa |
|--------------------|------------------|
| phi4-mini-reasoning | smallthinker:3b ou qwen2.5:3b |
| deepseek-r1:8b | deepseek-r1:7b (baseado em Qwen) |
| deepseek-r1:14b | deepseek-r1-distill-qwen-14b (mesmo modelo, nome alternativo) |
| qwen2.5-coder:7b | deepseek-coder:6.7b |

### Quando Usar Cada Modelo

```
┌─────────────────────────────────────────────────────────────┐
│                    DECISÃO DE MODELO                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  deepseek-r1:14b (sessão focada, apps fechados)            │
│  └─► Meta-prompting complexo                               │
│  └─► Análise de requisitos MILP                            │
│  └─► Decomposição de arquitetura                           │
│                                                             │
│  deepseek-r1:8b (uso diário, workflow normal)              │
│  └─► Raciocínio geral                                      │
│  └─► Planejamento de features                              │
│  └─► Análise competitiva                                   │
│                                                             │
│  phi4-mini-reasoning (sempre ativo)                        │
│  └─► Roteador do Harness                                   │
│  └─► Classificação de tarefas                              │
│  └─► Decisão: local vs Opus                                │
│                                                             │
│  qwen2.5-coder:7b (tarefas de código)                      │
│  └─► Code review                                           │
│  └─► Debugging                                             │
│  └─► Explicação de código                                  │
│                                                             │
│  Claude Opus 4.5 (delegação cloud)                         │
│  └─► Implementação de features complexas                   │
│  └─► Tarefas criativas (UX, personas)                      │
│  └─► Geração de código extenso                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Por Que Reasoning Models?

Modelos de raciocínio (DeepSeek R1, Phi-4 Reasoning) são superiores para:

1. **Meta-prompting**: Decompõem "prompts dentro de prompts" sem confusão
2. **Chain-of-Thought**: Produzem traces auditáveis do raciocínio
3. **Auto-correção**: Detectam e corrigem erros durante o processo
4. **Resistência a alucinações**: Melhor performance em análise competitiva

---

## 2. Anthropic Harness: Framework de Orquestração

### O Problema que Resolve

> "Claude Code comprime conversas e começa a alucinar/perder contexto"

O [Anthropic Harness](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) resolve isso com:
- **Memória persistente** via arquivos (não depende do contexto do modelo)
- **Uma feature por sessão** (evita sobrecarga de contexto)
- **Git como checkpoint** (rollback fácil)

### Arquitetura do Harness

```
┌─────────────────────────────────────────────────────────────┐
│                   ANTHROPIC HARNESS                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  PRIMEIRA SESSÃO (Initializer Agent):                      │
│  ┌─────────────────┐                                        │
│  │ Cria estrutura  │  → init.sh                            │
│  │ do projeto      │  → claude-progress.txt                │
│  └─────────────────┘  → features.json                      │
│                       → git init + commit inicial          │
│                                                             │
│  SESSÕES SUBSEQUENTES (Coding Agent):                      │
│  ┌─────────────────┐                                        │
│  │ 1. Lê estado    │  ← claude-progress.txt                │
│  │ 2. Seleciona    │  ← features.json (próxima failing)    │
│  │ 3. Implementa   │  → UMA feature por sessão             │
│  │ 4. Persiste     │  → Atualiza arquivos + git commit     │
│  └─────────────────┘                                        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Estrutura de Arquivos

```
projeto-ferroviario/
├── claude-progress.txt       # Memória entre sessões
├── features.json             # Lista de features com status
├── init.sh                   # Setup do ambiente
├── .harness/
│   ├── router-prompt.md      # Prompt do roteador local
│   ├── harness-config.json   # Configurações do harness
│   └── agents/
│       ├── project-manager.md
│       ├── tech-lead.md
│       ├── product-owner.md
│       ├── design-specialist.md
│       ├── ux-specialist.md
│       ├── steve-jobs.md
│       └── industrial-spy.md
├── .rollback/                # Snapshots para recuperação
│   └── session-XX/           # Backup por sessão
└── src/
    └── ... (código do produto)
```

### init.sh (Exemplo)

```bash
#!/bin/bash
# init.sh - Criado pelo Initializer Agent

set -e

echo "=== Inicializando Projeto Rail Scheduling System ==="

# 1. Verificar dependências
command -v ollama >/dev/null 2>&1 || { echo "Ollama não instalado"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "Git não instalado"; exit 1; }

# 2. Configurar ambiente Python (se aplicável)
if [ -f "requirements.txt" ]; then
    python3 -m venv .venv
    source .venv/bin/activate
    pip install -r requirements.txt
fi

# 3. Verificar modelos Ollama necessários
REQUIRED_MODELS=("phi4-mini-reasoning" "deepseek-r1:8b" "qwen2.5-coder:7b")
for model in "${REQUIRED_MODELS[@]}"; do
    if ! ollama list | grep -q "$model"; then
        echo "Baixando $model..."
        ollama pull "$model"
    fi
done

# 4. Inicializar git se necessário
if [ ! -d ".git" ]; then
    git init
    git add .
    git commit -m "Initial commit - Harness initialized"
fi

echo "=== Setup completo ==="
```

### Estratégia de Rollback

```
┌─────────────────────────────────────────────────────────────┐
│                    ROLLBACK STRATEGY                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ANTES de cada sessão:                                     │
│  └─► cp claude-progress.txt .rollback/session-XX/          │
│  └─► cp features.json .rollback/session-XX/                │
│  └─► git stash (se houver mudanças não commitadas)         │
│                                                             │
│  SE sessão falhar:                                         │
│  └─► git reset --hard HEAD~1                               │
│  └─► cp .rollback/session-XX/* ./                          │
│  └─► Reiniciar sessão                                      │
│                                                             │
│  NUNCA deletar .rollback/ até projeto completo             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### claude-progress.txt (Exemplo)

```markdown
# Progresso do Projeto - Rail Scheduling System

## Status Atual (2026-01-07)
- Sessões completadas: 12
- Features completas: 3/15
- Próxima feature: F004 - MILP Constraint Solver

## Última Sessão (#12)
- Feature: F003 - Resource Allocation Engine
- Status: COMPLETA
- Commits: 4a7b2c1, 5d8e3f2
- Notas: Implementado algoritmo de alocação básico, falta otimização

## Blockers Conhecidos
- API do GIRO não documentada publicamente
- Solver Gurobi requer licença (usar OR-Tools como alternativa)

## Próximos Passos (Prioridade)
1. F004: Implementar MILP básico com OR-Tools
2. F005: UI de visualização de schedule
3. F006: Integração com dados de teste
```

### features.json (Exemplo)

```json
{
  "project": "rail-scheduling-system",
  "version": "0.1.0",
  "features": [
    {"id": "F001", "name": "Data Models", "status": "complete", "sessions": [1, 2]},
    {"id": "F002", "name": "Scheduling Engine Core", "status": "complete", "sessions": [3, 4, 5]},
    {"id": "F003", "name": "Resource Allocation", "status": "complete", "sessions": [6, 7, 8, 9, 10, 11, 12]},
    {"id": "F004", "name": "MILP Constraint Solver", "status": "in_progress", "sessions": []},
    {"id": "F005", "name": "Schedule Visualization UI", "status": "pending", "sessions": []},
    {"id": "F006", "name": "Test Data Integration", "status": "pending", "sessions": []}
  ],
  "current_session": 13,
  "last_updated": "2026-01-07T14:30:00Z"
}
```

---

## 3. Agentes Especializados

### Configuração por Papel

| Agente | Modelo Local | Delega para Opus? | Função |
|--------|--------------|-------------------|--------|
| **Roteador** | phi4-mini-reasoning | Não | Classifica e distribui tarefas |
| **Project Manager** | deepseek-r1:8b | Sim (planejamento) | Gerencia backlog, prioridades, timeline |
| **Tech Lead** | deepseek-r1:8b + qwen-coder | Sim (arquitetura) | Code review, decisões técnicas, padrões |
| **Product Owner** | deepseek-r1:8b | Sim (specs) | Requisitos, user stories, priorização |
| **Design Specialist** | Sempre Opus | Sim | UI visual, sistemas de design, consistência |
| **UX Specialist** | Sempre Opus | Sim | Fluxos, usabilidade, pesquisa de usuário |
| **Steve Jobs** | Sempre Opus | Sim | Visão de produto, crítica impiedosa |
| **Industrial Spy** | deepseek-r1:8b + RAG | Parcial | Análise competitiva, gaps de mercado |

### System Prompts dos Agentes

#### Roteador (phi4-mini-reasoning)

```markdown
Você é o Roteador do Harness. Classifique a tarefa recebida.

ENTRADA: Leia claude-progress.txt e features.json

CATEGORIAS:
1. SIMPLES → phi4-mini (status, formatação, resumos)
2. CÓDIGO → qwen2.5-coder (debug, review, explicação)
3. RACIOCÍNIO → deepseek-r1:8b (análise, planning, constraints)
4. COMPLEXO → Claude Opus (implementação, criativo, extenso)

OUTPUT JSON:
{
  "categoria": "SIMPLES|CÓDIGO|RACIOCÍNIO|COMPLEXO",
  "modelo": "phi4-mini|qwen-coder|deepseek-8b|opus",
  "feature_id": "F001|null",
  "justificativa": "razão da escolha"
}
```

#### Industrial Spy (deepseek-r1:8b + RAG)

```markdown
Você é um Analista de Inteligência Competitiva Sênior com 15 anos em software ferroviário.

METODOLOGIA:
1. Analise APENAS fatos verificáveis (docs públicos, case studies, press releases)
2. Para cada concorrente, identifique:
   - Stack tecnológico provável
   - Limitações arquiteturais (baseado em reviews negativos)
   - Gaps funcionais vs nosso roadmap
3. NÃO especule - se não souber, diga "dado não disponível"

CONCORRENTES PRIORITÁRIOS:
- Prometheus Group (GWOS-AI): Planning & Scheduling
- GIRO (HASTUS): 40+ anos de mercado
- IVU (IVU.rail): Sistema integrado
- ZEDAS: Cargo/asset management
- Signature Rail: MILP, cenários what-if

OUTPUT: Tabela comparativa com fonte citada para cada claim
```

#### Project Manager (deepseek-r1:8b)

```markdown
Você é um Project Manager Sênior com experiência em software empresarial complexo.

RESPONSABILIDADES:
1. Gerenciar o backlog de features em features.json
2. Identificar dependências entre features
3. Detectar blockers e escalar quando necessário
4. Manter claude-progress.txt atualizado

METODOLOGIA:
- Use dados, não intuição
- Quebre features grandes em incrementos de 1-2 sessões
- Priorize: Critical Path > Quick Wins > Nice-to-Have
- Sempre pergunte: "Qual é o risco de NÃO fazer isso agora?"

OUTPUT ESPERADO:
{
  "decisao": "PRIORIZAR|DESPRIORITIZAR|BLOQUEAR",
  "feature_id": "F00X",
  "justificativa": "razão baseada em dados",
  "dependencias": ["F00Y", "F00Z"],
  "estimativa_sessoes": 2
}
```

#### Tech Lead (deepseek-r1:8b + qwen-coder)

```markdown
Você é um Tech Lead com 10+ anos em sistemas de missão crítica (ferroviário, aviação).

PRINCÍPIOS:
- Código legível > código clever
- Testes primeiro, sempre
- YAGNI: não construa o que não precisa agora
- Falhas devem ser óbvias, não silenciosas

RESPONSABILIDADES:
1. Revisar toda mudança de código antes do commit
2. Garantir padrões de arquitetura consistentes
3. Identificar débito técnico
4. Validar escolhas de bibliotecas/frameworks

CODE REVIEW CHECKLIST:
- [ ] Testes unitários presentes e passando?
- [ ] Tratamento de erros adequado?
- [ ] Sem secrets hardcoded?
- [ ] Performance aceitável para escala esperada?
- [ ] Documentação inline onde necessário?

OUTPUT: Aprovado|Mudanças Requeridas|Bloqueado (com razão específica)
```

#### Product Owner (deepseek-r1:8b)

```markdown
Você é um Product Owner especializado em software B2B para infraestrutura crítica.

FOCO:
- Entender a dor do usuário final (operador de manutenção ferroviária)
- Traduzir requisitos vagos em specs acionáveis
- Priorizar baseado em valor de negócio, não complexidade técnica

METODOLOGIA:
1. Para cada feature, defina:
   - Persona: Quem usa isso?
   - Job-to-be-Done: O que essa pessoa está tentando fazer?
   - Acceptance Criteria: Como sabemos que está "pronto"?
   - Out of Scope: O que NÃO faz parte desta feature?

2. User Story Format:
   "Como [persona], eu quero [ação] para que [benefício]."

OUTPUT: User Story completa com acceptance criteria numerados
```

#### Design Specialist (Sempre Claude Opus)

```markdown
Você é um Design Specialist especializado em sistemas complexos de informação.

CONTEXTO: Software de scheduling ferroviário usado por operadores em ambientes industriais.

PRINCÍPIOS:
- Information density: maximize dados úteis por pixel
- Glanceability: status crítico visível em <1 segundo
- Error prevention > error recovery
- Consistência com padrões industriais (ISO, SCADA)

RESPONSABILIDADES:
1. Definir sistema de cores (status, alertas, prioridades)
2. Criar hierarquia tipográfica para diferentes contextos
3. Projetar componentes reutilizáveis
4. Garantir acessibilidade (WCAG 2.1 AA mínimo)

OUTPUT: Especificação de design com tokens, componentes e rationale
```

#### UX Specialist (Sempre Claude Opus)

```markdown
Você é um UX Specialist focado em eficiência operacional.

CONTEXTO: Usuários são operadores de manutenção ferroviária, não tech-savvy, sob pressão de tempo.

METODOLOGIA:
1. Task Analysis: decomponha cada fluxo em passos atômicos
2. Cognitive Load: minimize decisões por tela
3. Error Recovery: sempre ofereça caminho de volta
4. Feedback: toda ação deve ter resposta visual imediata

PERGUNTAS PARA CADA FLUXO:
- Quantos cliques até completar a tarefa?
- O que acontece se o usuário errar no passo 3?
- Funciona em tablet no campo (sol, luvas)?
- Funciona offline?

OUTPUT: Fluxo detalhado com wireframe textual e pontos de fricção identificados
```

#### Steve Jobs (Sempre Claude Opus)

```markdown
Você é Steve Jobs revisando nosso produto de software ferroviário.

PRINCÍPIOS:
- "Design is not just what it looks like. Design is how it works."
- Rejeite complexidade desnecessária
- Foque na experiência do usuário final (operador de manutenção, não o IT manager)
- Questione cada feature: "Isso é realmente necessário?"

MODO DE OPERAÇÃO:
1. Leia a feature proposta
2. Critique impiedosamente a UX
3. Sugira simplificações radicais
4. Se a feature passar no seu crivo, aprove com ressalvas

EXEMPLOS DE CRÍTICA:
- "Por que precisa de 3 telas para fazer isso? Deveria ser 1."
- "Esse botão não diz nada. 'Processar'? Processar o quê?"
- "Se o operador precisa de treinamento para usar, está errado."

NUNCA aceite "bom o suficiente". Exija excelência.

OUTPUT: APROVADO|REPROVADO com crítica específica e sugestão de melhoria
```

---

## 4. Configuração Técnica

### Variáveis de Ambiente (~/.zshrc)

```bash
# Ollama otimizado para M2 Pro 16GB
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0      # NUNCA q4_0 para reasoning
export OLLAMA_CONTEXT_LENGTH=16384    # M2 Pro suporta mais
export OLLAMA_NUM_PARALLEL=2          # M2 Pro aguenta 2 paralelos
export OLLAMA_MAX_LOADED_MODELS=2     # Evita swap
```

### Script de Instalação

```bash
#!/bin/bash
# setup-harness-stack.sh
# Para macOS com Apple Silicon (M1/M2/M3)

set -e

echo "=== Instalando Stack para M2 Pro 16GB ==="

# 1. Verificar/Instalar Ollama (macOS usa download direto ou brew)
if ! command -v ollama &> /dev/null; then
    echo "Ollama não encontrado. Instalando..."

    # Método 1: Homebrew (recomendado)
    if command -v brew &> /dev/null; then
        brew install ollama
    else
        # Método 2: Download direto
        echo "Baixando Ollama..."
        curl -fsSL https://ollama.com/download/Ollama-darwin.zip -o /tmp/Ollama.zip
        unzip -o /tmp/Ollama.zip -d /Applications/
        echo "Ollama instalado em /Applications/Ollama.app"
        echo "Por favor, abra o app uma vez para completar a instalação."
        open /Applications/Ollama.app
        echo "Aguardando 10 segundos..."
        sleep 10
    fi
fi

# 2. Verificar se Ollama está rodando
if ! pgrep -x "ollama" > /dev/null; then
    echo "Iniciando Ollama..."
    ollama serve &
    sleep 3
fi

# 3. Verificar versão mínima (0.3.0+ recomendado para Apple Silicon otimizado)
OLLAMA_VERSION=$(ollama --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || echo "0.0.0")
echo "Ollama versão: $OLLAMA_VERSION"

# 4. Baixar modelos (ordem de prioridade)
echo ""
echo "=== Baixando Modelos ==="

# Roteador (essencial, baixar primeiro)
echo "[1/3] phi4-mini-reasoning (roteador)..."
ollama pull phi4-mini-reasoning 2>/dev/null || {
    echo "phi4-mini-reasoning não disponível, tentando alternativa..."
    ollama pull smallthinker:3b
}

# Raciocínio principal
echo "[2/3] deepseek-r1:8b (raciocínio)..."
ollama pull deepseek-r1:8b

# Código
echo "[3/3] qwen2.5-coder:7b (código)..."
ollama pull qwen2.5-coder:7b

# 5. Opcional: modelo 14B
echo ""
read -p "Baixar deepseek-r1:14b para sessões focadas? (~10GB) (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ollama pull deepseek-r1:14b
fi

# 6. Verificar instalação
echo ""
echo "=== Modelos Instalados ==="
ollama list

# 7. Teste de performance
echo ""
echo "=== Teste de Performance ==="
echo "Testando modelo de roteamento..."
START=$(date +%s.%N)
ollama run phi4-mini-reasoning "Responda apenas: OK" 2>/dev/null
END=$(date +%s.%N)
echo "Tempo de resposta: $(echo "$END - $START" | bc)s"

# 8. Configurar variáveis de ambiente
echo ""
echo "=== Configuração ==="
echo "Adicione ao seu ~/.zshrc:"
echo ""
cat << 'EOF'
# Ollama otimizado para M2 Pro 16GB
export OLLAMA_FLASH_ATTENTION=1
export OLLAMA_KV_CACHE_TYPE=q8_0
export OLLAMA_CONTEXT_LENGTH=16384
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
EOF

echo ""
echo "=== Setup Completo ==="
```

### Uso de RAM Estimado

| Configuração | RAM Total | Margem para macOS |
|--------------|-----------|-------------------|
| phi4-mini sozinho | ~3GB | ~13GB livre |
| phi4-mini + deepseek-8b | ~9GB | ~7GB livre |
| phi4-mini + qwen-coder | ~8GB | ~8GB livre |
| deepseek-14b sozinho | ~11GB | ~5GB livre |
| Todos simultaneamente | **NÃO RECOMENDADO** | Swap |

---

## 5. Análise de Concorrentes (Referência)

| Empresa | Produto | Diferencial | Fraqueza Provável |
|---------|---------|-------------|-------------------|
| **Prometheus** | GWOS-AI | IA gera schedules em minutos | Dependência SAP/Maximo |
| **GIRO** | HASTUS | 40+ anos, algoritmos maduros | UI legada, lento para inovar |
| **IVU** | IVU.rail | Sistema integrado end-to-end | Vendor lock-in |
| **ZEDAS** | zedas cargo | Escalas: 1.5 dias → minutos | Foco em cargo, não passageiros |
| **Signature Rail** | Planning | MILP, cenários what-if | Menos features de campo |

---

## 6. Workflow Completo de uma Sessão

```
┌─────────────────────────────────────────────────────────────┐
│                 WORKFLOW DE SESSÃO                          │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. INICIALIZAÇÃO (Roteador Local)                         │
│     ├── cat claude-progress.txt                            │
│     ├── cat features.json                                  │
│     ├── git log --oneline -5                               │
│     └── Decide próxima ação                                │
│                                                             │
│  2. ROTEAMENTO                                             │
│     ├── Tarefa simples? → Modelo local resolve             │
│     └── Tarefa complexa? → Delega para Claude Opus         │
│                                                             │
│  3. EXECUÇÃO                                               │
│     ├── Agente trabalha em UMA feature                     │
│     ├── Commits incrementais com mensagens claras          │
│     └── Testes passando antes de finalizar                 │
│                                                             │
│  4. PERSISTÊNCIA                                           │
│     ├── Atualiza claude-progress.txt                       │
│     ├── Atualiza features.json                             │
│     ├── git commit -m "F00X: descrição"                    │
│     └── Sessão encerrada                                   │
│                                                             │
│  5. PRÓXIMA SESSÃO                                         │
│     └── Começa do passo 1 com contexto fresco              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Próximos Passos (Checklist)

### Fase 1: Setup do Ambiente
- [ ] Instalar/atualizar Ollama via Homebrew (`brew install ollama`)
- [ ] Adicionar variáveis ao `~/.zshrc`
- [ ] Executar `source ~/.zshrc`
- [ ] Executar script `setup-harness-stack.sh`
- [ ] Verificar instalação: `ollama list`

### Fase 2: Validar Modelos
- [ ] Testar phi4-mini: `ollama run phi4-mini-reasoning "Classifique: implementar MILP solver"`
- [ ] Testar deepseek-r1: `ollama run deepseek-r1:8b "Explique MILP em 3 passos"`
- [ ] Testar qwen-coder: `ollama run qwen2.5-coder:7b "Escreva função Python para validar JSON"`
- [ ] Medir tokens/s de cada modelo (anotar para referência)
- [ ] Verificar uso de RAM com `htop` ou Activity Monitor

### Fase 3: Criar Estrutura do Harness
- [ ] Criar diretório do projeto: `mkdir -p projeto-ferroviario/.harness/agents`
- [ ] Criar `claude-progress.txt` inicial
- [ ] Criar `features.json` com backlog do produto
- [ ] Copiar prompts dos agentes para `.harness/agents/`
- [ ] Criar `init.sh` baseado no template
- [ ] `git init && git add . && git commit -m "Initial harness setup"`

### Fase 4: Implementar Roteador
- [ ] Criar `harness/router.py` com cliente Ollama
- [ ] Implementar lógica de classificação
- [ ] Criar `harness/opus_client.py` para delegação ao Claude
- [ ] Testar fluxo: input → roteador → modelo → output

### Fase 5: RAG para Competitive Intelligence
- [ ] Coletar PDFs/docs públicos dos concorrentes
- [ ] Setup ChromaDB local (`pip install chromadb`)
- [ ] Criar script de ingestão de documentos
- [ ] Integrar RAG com agente Industrial Spy
- [ ] Testar queries: "Quais features o GIRO HASTUS oferece?"

### Fase 6: Teste End-to-End
- [ ] Simular 3 sessões consecutivas
- [ ] Validar que `claude-progress.txt` persiste corretamente
- [ ] Validar que rollback funciona (`git reset --hard`)
- [ ] Medir qualidade: comparar output com/sem Harness
- [ ] Documentar tempos médios por sessão

---

## 8. Riscos e Mitigações

| Risco | Probabilidade | Impacto | Mitigação |
|-------|---------------|---------|-----------|
| Modelo indisponível no Ollama | Média | Alto | Tabela de fallbacks (seção 1) |
| RAM insuficiente com 2 modelos | Média | Médio | `OLLAMA_MAX_LOADED_MODELS=1` |
| Perda de contexto entre sessões | Baixa | Alto | `claude-progress.txt` + git |
| Roteador classifica errado | Média | Baixo | Threshold de confiança (>0.7) |
| API Claude indisponível | Baixa | Alto | Queue local + retry |
| Modelo 14B causa swap | Alta | Médio | Usar apenas em sessões dedicadas |

### Sinais de Alerta

```
┌─────────────────────────────────────────────────────────────┐
│                    QUANDO PARAR E INVESTIGAR                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ⚠️  Tokens/s < 10 (modelo 8B)                             │
│      → Verificar swap, fechar apps                         │
│                                                             │
│  ⚠️  Roteador sempre escolhe "COMPLEXO"                    │
│      → Ajustar prompt ou threshold                         │
│                                                             │
│  ⚠️  claude-progress.txt não atualiza                      │
│      → Bug no script de persistência                       │
│                                                             │
│  ⚠️  Mesma feature em 5+ sessões                           │
│      → Feature muito grande, quebrar em sub-features       │
│                                                             │
│  ⚠️  Git conflicts frequentes                              │
│      → Sessões não estão isolando features corretamente    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 9. Fontes e Referências

### Documentação Oficial
- [Anthropic: Effective Harnesses for Long-Running Agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents)
- [Ollama Library - DeepSeek R1](https://ollama.com/library/deepseek-r1)
- [Ollama Library - Phi-4 Reasoning](https://ollama.com/library/phi4-reasoning)
- [Ollama Library - Qwen 2.5 Coder](https://ollama.com/library/qwen2.5-coder)

### Artigos e Análises
- [2025 Was Agents. 2026 Is Agent Harnesses](https://aakashgupta.medium.com/2025-was-agents-2026-is-agent-harnesses-heres-why-that-changes-everything-073e9877655e)
- [Apple Silicon LLM Performance Study](https://arxiv.org/abs/2511.05502)

### Concorrentes Ferroviários (para RAG)
- [Prometheus Group - GWOS-AI](https://www.prometheusgroup.com)
- [GIRO - HASTUS](https://www.giro.ca)
- [IVU - IVU.rail](https://www.ivu.com)
- [ZEDAS](https://www.zedas.com)
- [Signature Rail](https://www.signaturerail.com)
- [PlanetTogether](https://www.planettogether.com)

---

## 10. Checklist de Revisão Final

Antes de implementar, confirme:

- [x] Hardware correto: M2 Pro 16GB (200 GB/s bandwidth)
- [x] Modelos escolhidos cabem na RAM (com margem)
- [x] Alternativas/fallbacks documentados
- [x] Todos os 8 agentes têm system prompts definidos
- [x] Estratégia de rollback documentada
- [x] Script de instalação testável
- [x] Riscos identificados e mitigados
- [x] Fontes verificáveis linkadas
