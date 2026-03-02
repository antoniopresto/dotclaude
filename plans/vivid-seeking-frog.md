# Plan: Final Architecture Document

## Summary
Write a concise architecture document for the CPF Queue automation. The document will consolidate 8 iterations into a clean, natural-sounding high-level blueprint.

## Output File
`.claude/internal-docs/SOLUTION_FINAL.md`

## Key Decisions Extracted from Reviews

### Architecture
- DynamoDB persistence (not RDS) - serverless, pay-per-use
- Single-region with S3 cross-region backup (not Global Tables) - adequate for 48h SLA
- EventBridge Pipes for stream fan-out (not direct DynamoDB Streams)
- Private API Gateway (no WAF needed for internal use)
- DynamoDB-backed circuit breaker (not SSM - avoids race conditions)

### Security (LGPD)
- HMAC-SHA256 with secret key in Secrets Manager (not plain SHA-256 - rainbow table protection)
- KMS encryption for CPF data with multi-region key
- Versioned tokens (`v1:hash`) for key rotation without data loss
- LGPD endpoints: DELETE and EXPORT for data subject rights
- Per-CPF rate limiting on data subject endpoints

### Reliability
- Circuit breaker only triggers on INFRASTRUCTURE errors (not business errors)
- Exponential backoff: `min(retry² × 5min + jitter, 6h)`
- Max 10 retries before FAILED_PERMANENT
- Processing locks to prevent thundering herd
- Archive verification before TTL deletion

### Callback
- FeeExemption publishes success event to EventBridge (decoupled)
- Idempotency key required: `{cpf}:{period}:{date}`

### Open Items (Blocking)
- CBILL idempotency support verification
- FeeExemption callback implementation

## Document Structure
1. Problema (2-3 lines)
2. Solução (mermaid diagram + brief component list)
3. Decisões de Arquitetura (table format)
4. Segurança (LGPD summary)
5. Itens em Aberto

## Style Guidelines
- Portuguese language
- No version references
- No code snippets
- No CloudFormation/IAM
- Natural writing (not formulaic)
- ~150-200 lines max
- **Mermaid diagrams** (not ASCII art - compatible with Excalidraw, Notion, GitHub)
