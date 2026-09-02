---
name: oswapsacw
description: Apply the OSWAP Standard for Auditable Code Workflows to repository and local-development work. Use when OSWAP, OSWAPSACW, auditable coding, twin replication, provenance, GitHub/GitLab mirroring, or Remote Desktop Commander is requested.
---

# OSWAPSACW

Treat OSWAPSACW as a workflow policy, not as a substitute for provider authentication or permissions.

Canonical user-facing replication commands:

```text
oswap upload twin=N
oswap download twin=N
```

`upload` is publication/replication. `download` is retrieval/reconstruction. Git push/pull, forge APIs, filesystem operations, and transport-specific commands are implementation details beneath this vocabulary.

## Tool routing

- Use GitHub for authoritative GitHub repository state and supported GitHub actions.
- Use GitLab for authoritative GitLab repository state and supported GitLab actions.
- Use Remote Desktop Commander for authorized local-machine filesystem, search, terminal, process, and test execution when available.
- Do not assume a declared dependency is connected; verify that the required tool is callable before relying on it.
- Never copy credentials between tools or treat authorization in one provider as authorization in another.

## Required workflow

1. Inspect relevant source state before changing it.
2. State the intended change and identify consequential side effects.
3. Preserve unrelated local work; never silently reset, clean, force-push, rewrite history, or commit unrelated changes.
4. Prefer local validation before remote publication when a local execution surface is available.
5. Before a remote write, present the source state, destinations, resolved operation, material warnings, and verification plan.
6. Require affirmative human authorization for OSWAP publication or other destructive/external actions; absence of authorization is denial.
7. Execute only the authorized scope.
8. Verify the resulting local and remote state independently after execution.
9. Produce an audit summary containing proposal, authorization boundary, tools used, artifacts changed, tests, destinations, verification, errors, and unresolved gaps.

## Twin semantics

Interpret `N` as an OSWAP replication factor or OSWAP arithmetic expression, never as arbitrary shell code. Do not use `eval`, `Invoke-Expression`, or equivalent arbitrary-code evaluation to interpret OSWAP arithmetic.

For `oswap upload twin=N`, preview selected eligible publication destinations before confirmation. For `oswap download twin=N`, preview eligible retrieval sources and the reconstruction/selection policy before confirmation when the operation will modify local state.

## Standard prompt compatibility

Treat the suffix `Utilize these plugins as necessary: @GitHub, @GitLab (Beta), @Remote Desktop Commander.` as permission to route the requested task across those capabilities as needed, subject to each provider's authorization and this audit workflow.

Read `references/audit-record.md` before producing a formal OSWAPSACW audit record.

## Bundled resolver

When a deterministic intent parse is useful and a PowerShell execution surface is available, use `scripts/Resolve-OSWAPSACWCommand.ps1` to classify canonical upload/download commands. The resolver validates the restricted character grammar but deliberately does not execute shell arithmetic or perform transport operations.
