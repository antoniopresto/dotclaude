# Plano: Consolidar Documentação da Spike CPF Queue

## Objetivo

Criar uma versão final do documento de arquitetura para a spike SPMAIS-33885 que seja:
- Sucinta e direta (estilo V0)
- Natural, sem parecer gerado por AI
- Sem referências a histórico de versões
- Com todos os detalhes necessários para o desenvolvedor implementar

## Decisões do Usuário

- **Idioma**: Português
- **Nível de detalhe**: Schema DynamoDB + endpoints API
- **CBILL idempotency**: Marcar como pendente (time precisa validar)

## Análise das Versões Existentes

| Versão | Características | Problemas |
|--------|----------------|-----------|
| V0 | Direta, simples | Falta detalhes técnicos |
| V1-V4 | Muito detalhada, código incluso | Over-engineering, parece AI |
| V5-V6 | Foco arquitetural | Ainda verbosa |
| V7 | Mais completa, feedback integrado | Muito longa, histórico de versões |
| V8 | Sucinta, diagramas Mermaid | Boa base, mas ainda menciona versões |

## Descobertas dos Repositórios

**NTS-App-Fintech-promotionControl** (relevante):
- Lambda `FeeExemption` já existe e processa a fila
- `DynamoDBService` com operações batch pode ser reutilizado
- `SqsService` para operações de fila
- Fluxo: SQS → Lambda → 3 chamadas GraphQL → CBILL
- DLQ: `APP_ISENCAO_MENSALIDADE_CARTAO-Erro`

**Gaps identificados**:
- Não existe persistência de falhas
- Não existe mecanismo de replay
- CBILL idempotency não verificada (BLOCKER)

## Estrutura do Documento Final

```
1. Problema (2-3 parágrafos)
2. Solução (diagrama + componentes)
3. Decisões de Arquitetura (tabela)
4. Segurança/LGPD (resumo)
5. Fluxos de Dados (principais)
6. Observabilidade (alarmes críticos)
7. Fases de Implementação (4 fases)
8. Itens Bloqueantes
```

## Princípios para Escrita

1. **Tom**: Técnico mas acessível, como um arquiteto explicando para o time
2. **Formato**: Preferir tabelas e listas a parágrafos longos
3. **Diagramas**: Mermaid para visualização
4. **Detalhes**: Incluir o suficiente para implementar, não para documentar NASA
5. **Decisões**: Justificar escolhas sem over-explaining

## Arquivo de Destino

`/Users/anotonio.silva/dev/rnm-app-fintech-rewardprogram/.claude/internal-docs/SOLUTION_FINAL.md`

## Conteúdo do Documento Final

### 1. Problema (~5 linhas)
- O que falha, onde vai parar, o que se perde

### 2. Solução (~20 linhas)
- Diagrama Mermaid do fluxo proposto
- Lista dos componentes novos

### 3. Schema DynamoDB
```
Tabela: fee_exemption_failures
- PK: cpf_token (HMAC-SHA256)
- SK: created_at
- Atributos: cpf_encrypted, status, error_code, retry_count, payload, ttl
- GSI: status-created_at-index
```

### 4. Endpoints API (a criar)
```
GET  /v1/failures           - Listar falhas com filtros
GET  /v1/failures/{cpf}     - Falhas de um CPF
POST /v1/replay             - Disparar replay manual
GET  /v1/health             - Status do sistema
```

### 5. Componentes
| Componente | Função |
|------------|--------|
| DLQ-Consumer | Persiste falhas no DynamoDB |
| Replay Lambda | Re-injeta na fila principal |
| Circuit Breaker | Protege contra cascata |
| API Gateway | Interface manual para Squad |

### 6. Decisões de Arquitetura (tabela resumida)

### 7. Segurança (CPF tokenizado + criptografado)

### 8. Fases de Implementação
- Fase 0: Pré-requisitos (KMS, VPC endpoints)
- Fase 1: Core (DLQ-Consumer + DynamoDB + Replay)
- Fase 2: Operações (API + Health Check + Alarmes)
- Fase 3: Validação (Testes + Deploy)

### 9. Itens Bloqueantes
- [ ] Verificar suporte a idempotency no CBILL
- [ ] Confirmar existência de VPC endpoints

## Arquivos Modificados

- **Criar**: `.claude/internal-docs/SOLUTION_FINAL.md`
- **Manter**: Versões anteriores para histórico (não deletar)

## Verificação

- [ ] Documento não menciona versões anteriores
- [ ] Não usa frases típicas de AI
- [ ] Inclui schema DynamoDB completo
- [ ] Inclui endpoints da API
- [ ] Lista itens bloqueantes claramente
- [ ] Tamanho: ~200-250 linhas (conciso mas completo)
