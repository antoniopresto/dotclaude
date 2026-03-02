# Plano de Revisão: SOLUTION_FINAL.md

## Resumo da Revisão

Após análise detalhada do código real em `NTS-App-Fintech-promotionControl` e validação contra a documentação do JIRA, identifiquei os seguintes pontos a corrigir no documento `SOLUTION_FINAL.md`.

---

## Correções Necessárias

### 1. Idioma
**Problema:** Documento escrito em inglês.
**Correção:** Reescrever em português conforme solicitado.

### 2. CloudWatch Data Protection Policy JSON
**Problema:** Estrutura JSON incorreta para custom data identifiers.

**Errado (atual):**
```json
{
  "Statement": [{
    "DataIdentifier": [{
      "Name": "CPF",
      "Regex": "..."
    }]
  }]
}
```

**Correto:**
```json
{
  "Name": "CPF-Masking-FeeExemption",
  "Version": "2021-06-01",
  "Configuration": {
    "CustomDataIdentifier": [
      { "Name": "CPF", "Regex": "\\d{3}\\.?\\d{3}\\.?\\d{3}-?\\d{2}" }
    ]
  },
  "Statement": [{
    "Sid": "MaskCPF",
    "DataIdentifier": ["CPF"],
    "Operation": {
      "Deidentify": { "MaskConfig": {} }
    }
  }]
}
```

### 3. Clarificar "10 tentativas"
**Problema:** Não estava claro de onde vem o número 10.
**Correção:** Referenciar SPMAIS-33590 e SPMAIS-33563 como fontes. Esclarecer que são retries de negócio (chamadas GraphQL), não de transporte SQS.

### 4. Simplificar o documento
**Problema:** Documento extenso com detalhes que podem ser desnecessários para uma spike.
**Correção:** Remover seções opcionais e manter foco na solução principal.

---

## Verificações Realizadas

| Item | Status | Observação |
|------|--------|------------|
| Código `ProcessUserPromotion.ts` | ✅ Verificado | Linhas 37-59 confirmam padrão de DLQ manual |
| Código `index-FeeExemption.ts` | ✅ Verificado | Confirma 3 SqsServices injetados |
| Código `classifyError.ts` | ✅ Verificado | Classifica erros como business/system |
| Código `SqsService.ts` | ✅ Verificado | sendToSQS e deleteFromSQS confirmados |
| Env vars das filas | ✅ Verificado | QUEUE_APP_ISENCAO_MENSALIDADE_CARTAO, _ERRO, _EMAIL |
| 10 tentativas | ✅ Documentado | SPMAIS-33590 e SPMAIS-33563 |
| AWS SQS Redrive API | ✅ Atualizado | StartMessageMoveTask suporta velocity control |
| CloudWatch Data Protection | ✅ Corrigido | CPF não é managed identifier, requer custom |

---

## Arquivos a Modificar

1. **`.claude/SOLUTION_FINAL.md`**
   - Reescrever em português
   - Corrigir JSON do CloudWatch Data Protection Policy
   - Adicionar referências aos tickets JIRA para as 10 tentativas
   - Simplificar mantendo apenas o essencial

---

## Estrutura do Documento Final

1. **Problema** - 1 parágrafo
2. **Diagnóstico** - Código atual + por que bloqueia reprocessamento
3. **Solução**
   - Alteração no ProcessUserPromotion.ts
   - Configuração SQS (RedrivePolicy, batchSize)
   - Desacoplamento da notificação
   - Fluxo de reprocessamento via Console AWS
4. **Observabilidade** - Alarmes essenciais
5. **LGPD** - Mascaramento de CPF (JSON correto)
6. **Plano de Implementação** - Fases
7. **Itens Bloqueantes** - Tabela
8. **Referências**

---

## Verificação

Após implementar as correções:
- Ler o documento completo para garantir fluência em português
- Validar todos os trechos de código contra os arquivos reais
- Confirmar que JSON do CloudWatch está no formato correto
- Verificar que não há linguagem "AI-like" ou gráficos ASCII
