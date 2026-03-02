# Review 360° — Fixes Required

## CRITICAL: Handler swallows errors — SQS native retry will never trigger

`index-FeeExemption.ts` line 54-62: the `catch` block calls `callbackSTP.send(response)` but **never re-throws**. Since `execute` is an `async` function, the resolved promise tells Lambda the invocation succeeded. SQS then deletes the message — it's never retried or moved to DLQ natively.

The old code compensated by manually sending to DLQ and deleting. My refactoring removed that manual flow but didn't fix the handler to propagate the error. **Result: failed messages silently disappear.**

**Fix:** Re-throw after the STP callback so the Lambda invocation fails and SQS retries.

```typescript
catch (error) {
    const response = { ... };
    callbackSTP.send(response);
    throw error; // ← add this
}
```

## HIGH: Deploy configs missing MAX_RECEIVE_COUNT

All three deploy files (DEV, QA, PRD) lack `MAX_RECEIVE_COUNT` in `Environment.Variables`. Without it, the code defaults to `3`, but this must be explicit and match the SQS RedrivePolicy `maxReceiveCount`.

**Fix:** Add `"MAX_RECEIVE_COUNT": "3"` to each deploy JSON.

## MEDIUM: JSON.parse(event.body) moved outside try-catch

`ProcessUserPromotion.ts` line 19: `JSON.parse` is now before the try block. If `event.body` is malformed, no structured log is emitted and no email is sent. The error just bubbles up unlogged.

Before: both parses were inside try/catch (though the catch parse would also fail, masking the error). Now: cleaner failure but no diagnostic log.

**Fix:** Wrap the parse in its own try-catch or move back inside.

## LOW: Orphaned env vars and code

- `QUEUE_APP_ISENCAO_MENSALIDADE_CARTAO` env var in deploy files — no longer referenced by code (was used for `sqsService.deleteFromSQS`)
- `QUEUE_APP_ISENCAO_MENSALIDADE_CARTAO_ERRO` env var in deploy files — no longer referenced by code (was used for `sqsDLQService.sendToSQS`)
- `main-FeeExemption.ts` lines 14-15 still set both orphaned env vars
- `SqsService.deleteFromSQS` method still exists — no longer called from this flow but may be used by other Lambda handlers

**Fix:** Remove orphaned env vars from deploy files and `main-FeeExemption.ts`. Keep `deleteFromSQS` in `SqsService` (shared infrastructure).

## LOW: Email payload still contains raw CPF

`ProcessUserPromotion.ts` line 63: `body` (including `identification` in plaintext) is sent to the email queue. Logs are masked, but the email payload isn't.

**Acceptable if:** The email service needs the real CPF to identify the customer. **Flag if:** LGPD compliance requires masking at rest/transit.

No code change needed unless LGPD policy mandates it.

## Files to change

1. `index-FeeExemption.ts` — add `throw error` in catch block
2. `ProcessUserPromotion.ts` — wrap `JSON.parse` for resilience
3. `deploy-FeeExemption-DEV.json` — add `MAX_RECEIVE_COUNT`, remove orphaned env vars
4. `deploy-FeeExemption-QA.json` — same
5. `deploy-FeeExemption-PRD.json` — same
6. `main-FeeExemption.ts` — remove orphaned env vars
7. `src/tests/index-FeeExemption.test.ts` — update error test to expect throw
