# Plano: Spike SPMAIS-33885 - Documento de Solução

## Status: Documento criado

Arquivo gerado: `.claude/internal-docs/SOLUTION_V12.md`

## Resumo do documento

### Problemas identificados no código atual

1. **Não existe retry automático** — primeira falha já vai para DLQ
2. **Redrive via Console não funciona** — mensagens enviadas manualmente perdem metadata
3. **StateMachine pode deletar mensagens da DLQ** — se for Lambda trigger
4. **Possível duplicação de emails** — código + StateMachine enviam
5. **throw após delete** — bug arquitetural

### Solução proposta

1. Modificar `ProcessUserPromotion.ts` — remover envio manual para DLQ
2. Modificar `index-FeeExemption.ts` — propagar erro ao runtime
3. Configurar `RedrivePolicy` na fila SQS
4. Ajustar StateMachine para não deletar da DLQ (ou substituir por CloudWatch Alarm)

### Itens a validar antes de implementar

- RedrivePolicy existe na fila principal?
- StateMachine é trigger na DLQ?
- CBILL é idempotente?
- Onde estão as "10 tentativas" mencionadas na spec?

### Estimativa

1-2 dias de desenvolvimento + 1 dia de validação

### Custo

$0 (usa SQS nativo)
