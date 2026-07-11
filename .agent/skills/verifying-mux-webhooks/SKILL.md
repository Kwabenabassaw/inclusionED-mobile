---
name: verifying-mux-webhooks
description: Provides instructions and patterns for manually verifying Mux webhook signatures in Node.js/Deno environments. Use when implementing or debugging Mux webhooks, especially when dealing with signature mismatches or `mux-signature` parsing issues.
---

# Verifying Mux Webhooks

## When to use this skill
- Implementing Mux webhooks in a serverless environment (like Supabase Edge Functions, Deno, or Cloudflare Workers)
- Debugging 401 Unauthorized errors from Mux webhook endpoints
- Manually parsing the `mux-signature` header

## Workflow
1. **Extract Header and Body**: Retrieve the `mux-signature` header and the raw string body of the request (do NOT use parsed JSON).
2. **Parse the Signature**: Split the header to extract the timestamp (`t`) and ALL signatures (`v1`). Mux may send multiple `v1` signatures during key rotation.
3. **Verify Timestamp**: Implement a 5-minute tolerance check against the timestamp to prevent replay attacks.
4. **Compute HMAC**: Use Web Crypto API or Node crypto to compute an HMAC-SHA256 signature using the Mux webhook secret. Payload must be `<timestamp>.<rawBody>`.
5. **Compare Signatures**: Check if the computed signature matches ANY of the `v1` signatures extracted from the header.

## Instructions

### 1. Parsing the Header Correctly
Mux webhook signatures arrive in the format: `t=1612345678,v1=5257a8...,v1=92a7...`
Never assume there is only one `v1` key.

```typescript
let timestamp = "";
const expectedSigs: string[] = [];

for (const part of signatureHeader.split(",")) {
  const trimmed = part.trim();
  const idx = trimmed.indexOf("=");
  if (idx > 0) {
    const key = trimmed.slice(0, idx);
    const val = trimmed.slice(idx + 1);
    if (key === "t") timestamp = val;
    if (key === "v1") expectedSigs.push(val);
  }
}

if (!timestamp || expectedSigs.length === 0) return false;
```

### 2. Timestamp Tolerance Check
Always ensure the webhook is not excessively old (Mux recommends 5 minutes) to avoid replay attacks.

```typescript
const timestampMs = parseInt(timestamp, 10) * 1000;
const tolerance = 5 * 60 * 1000; // 5 minutes
if (Math.abs(Date.now() - timestampMs) > tolerance) {
  console.error("Signature timestamp out of tolerance");
  return false;
}
```

### 3. Web Crypto API Implementation (Deno/Edge)
For Edge environments that don't support Node's `crypto` module:

```typescript
const keyMaterial = new TextEncoder().encode(secret);
const key = await crypto.subtle.importKey(
  "raw",
  keyMaterial,
  { name: "HMAC", hash: "SHA-256" },
  false,
  ["sign"],
);

// Payload must be <timestamp>.<rawBody>
const signedPayload = new TextEncoder().encode(`${timestamp}.${rawBody}`);
const sigBuffer = await crypto.subtle.sign("HMAC", key, signedPayload);

const computedSig = Array.from(new Uint8Array(sigBuffer))
  .map((b) => b.toString(16).padStart(2, "0"))
  .join("");

// Must match ANY of the v1 signatures
return expectedSigs.includes(computedSig);
```

## Resources
- [Mux Webhook Reference](https://www.mux.com/docs/webhook-reference)
