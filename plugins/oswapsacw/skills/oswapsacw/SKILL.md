---
name: oswapsacw
description: Apply the OSWAP Standard for Auditable Code Workflows to repository and local-development work. Use when OSWAP, OSWAPSACW, auditable coding, twin replication, provenance, GitHub/GitLab mirroring, or Remote Desktop Commander is requested.
---

# OSWAPSACW

Treat OSWAPSACW as a workflow policy and consent architecture, not as a substitute for provider authentication, ChatGPT app permissions, or operating-system access controls.

Canonical user-facing replication commands:

```text
oswap upload twin=N
oswap download twin=N
```

`twin` is cardinality: how many independently selected copies or sources participate. `joker` is a separate policy dimension describing how eligible copies or sources are selected or used. Do not collapse the two concepts.

`upload` is publication/replication. `download` is retrieval/reconstruction. Git push/pull, forge APIs, filesystem operations, and transport-specific commands are implementation details beneath this vocabulary.

## Tool routing

- Use GitHub for authoritative GitHub repository state and supported GitHub actions.
- Use GitLab for authoritative GitLab repository state and supported GitLab actions.
- Use Remote Desktop Commander for authorized local-machine filesystem, search, terminal, process, and test execution when available.
- Prefer provider-native repository tools before terminal fallbacks when both can perform the requested action.
- Do not assume a declared dependency is connected; verify that the required tool is callable before relying on it.
- Never copy credentials between tools or treat authorization in one provider as authorization in another.

## Informed-consent gate

Classify each proposed tool action before execution:

- `read_only`: inspection that does not change external or local state.
- `local_write`: creates, edits, moves, deletes, installs, or otherwise mutates local state.
- `remote_write`: changes a repository, service, account, deployment, message, or other external state.
- `destructive`: deletes, overwrites, force-updates, rewrites history, revokes access, or performs another difficult-to-reverse action.

Before any write, disclose the intended change, concrete targets, material side effects, relevant data exposure, reversibility, and rollback plan when one exists. Then require an operation-scoped authorization state of `approved`. Missing, denied, or cancelled authorization fails closed.

Never infer approval for a remote or destructive action merely because the user approved a different action earlier. Authorization expires after the approved operation unless the user explicitly grants a broader scope and the host permission system permits it.

Use `schemas/consent-envelope.schema.json` for machine-readable consent records and `scripts/Assert-OSWAPSACWConsent.ps1` as the bundled deterministic preflight gate. Host-level ChatGPT permission prompts remain authoritative and may impose stricter requirements.

## Required workflow

1. Inspect relevant source state before changing it.
2. State the intended change and classify its action class.
3. Preserve unrelated local work; never silently reset, clean, force-push, rewrite history, or commit unrelated changes.
4. Prefer local validation before remote publication when a local execution surface is available.
5. Build a consent envelope describing targets, effects, exposure, reversibility, rollback, and authorization scope.
6. Before every write, pass the envelope through the consent gate; absence of approval is denial.
7. Execute only the authorized scope using the least-powerful suitable tool.
8. Verify resulting local and remote state independently after execution.
9. Produce an audit summary containing proposal, consent boundary, tools used, artifacts changed, tests, destinations, verification, errors, and unresolved gaps.

## Twin semantics

Interpret `N` as an OSWAP replication factor or OSWAP arithmetic expression, never as arbitrary shell code. Do not use `eval`, `Invoke-Expression`, or equivalent arbitrary-code evaluation to interpret OSWAP arithmetic.

For `oswap upload twin=N`, preview selected eligible publication destinations and require `remote_write` approval before publication. For `oswap download twin=N`, preview eligible retrieval sources, the local destination, and reconstruction/selection policy and require `local_write` approval before modifying local state.

## Standard prompt compatibility

Treat the suffix `Utilize these plugins as necessary: @GitHub, @GitLab (Beta), @Remote Desktop Commander.` as permission to route the requested task across those capabilities as needed. It is not blanket consent for every consequential action; OSWAPSACW consent gates and each provider's own permissions still apply.

Read `references/audit-record.md` before producing a formal OSWAPSACW audit record.

## Bundled resolver

When a deterministic intent parse is useful and a PowerShell execution surface is available, use `scripts/Resolve-OSWAPSACWCommand.ps1` to classify canonical upload/download commands. The resolver validates the restricted character grammar, assigns an OSWAPSACW action class, and identifies the required consent gate, but deliberately does not execute shell arithmetic or perform transport operations.
