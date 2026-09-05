# OSWAPSACW ChatGPT Plugin

SPDX-License-Identifier: Apache-2.0

Experimental open-source Plugin for the Open-Source World Access Project (OSWAP) Standard for Auditable Code Workflows.

This project targets OpenAI-supported ChatGPT Plugin, Apps SDK, skill, and MCP integration mechanisms. It is not represented as created, certified, endorsed, or supported by OpenAI unless OpenAI separately agrees to such a statement in writing.

Canonical OSWAP replication vocabulary:

```text
oswap upload twin=N
oswap download twin=N
```

`twin` is cardinality: the number of independently selected copies or sources. `joker` is a separate policy dimension controlling how eligible copies or sources are selected or used.

The Plugin packages a reusable OSWAPSACW workflow skill, optional GitHub and GitLab connected-app bindings, and Remote Desktop Commander as a hosted MCP execution backend.

## Design boundary

OSWAPSACW orchestrates capabilities; it does not merge credentials, bypass provider permissions, or override ChatGPT app permission controls. GitHub, GitLab, Remote Desktop Commander, ChatGPT, and the host operating system retain their own authorization boundaries.

Remote Desktop Commander is used for authorized local filesystem and terminal work. Because its tools execute with the paired machine user's permissions, consequential work remains preview-first, consent-gated, and independently verified.

## Informed-consent architecture

OSWAPSACW 0.2 introduces a deterministic preflight gate for mutations. Actions are classified as `read_only`, `local_write`, `remote_write`, or `destructive`.
Every write must disclose its target, material side effects, relevant data exposure, reversibility, rollback plan when available, and authorization scope. Missing, denied, or cancelled authorization fails closed.

The machine-readable contract is `plugins/oswapsacw/schemas/consent-envelope.schema.json`. The bundled PowerShell preflight is `plugins/oswapsacw/scripts/Assert-OSWAPSACWConsent.ps1`.

This consent layer is additive. Host-level ChatGPT approval prompts and provider permissions remain authoritative and may require stricter approval or block an action entirely.

## Repository layout

```text
.agents/plugins/marketplace.json
plugins/oswapsacw/.codex-plugin/plugin.json
plugins/oswapsacw/.app.json
plugins/oswapsacw/.mcp.json
plugins/oswapsacw/skills/oswapsacw/SKILL.md
plugins/oswapsacw/schemas/audit-record.schema.json
plugins/oswapsacw/schemas/consent-envelope.schema.json
plugins/oswapsacw/scripts/Assert-OSWAPSACWConsent.ps1
plugins/oswapsacw/scripts/Resolve-OSWAPSACWCommand.ps1
plugins/oswapsacw/tests/Test-OSWAPSACW.ps1
docs/OSWAP_TECH_ASSISTED_WORKFLOWS.md
docs/OSWAP_LLM_EPISTEMIC_GUARDRAIL.md
```

## Local validation

```powershell
powershell -NoProfile -File .\plugins\oswapsacw\tests\Test-OSWAPSACW.ps1
```
The conformance test verifies plugin manifests, canonical transfer syntax, arithmetic-safety policy, consent classification, and the fail-closed behavior of approved, denied, and missing authorization states.

## Current transport status

This prototype does not itself implement repository transport. It standardizes ChatGPT/Codex orchestration around OSWAP semantics and delegates actual repository/local operations to authorized tools.

`oswap upload twin=N` resolves to a `remote_write` operation and requires consent before publication. `oswap download twin=N` resolves to a `local_write` operation and requires consent before local mutation.

The resolver currently implements canonical `twin` transfer parsing only. Planned `joker` policy expressions remain a distinct extension point and must not be silently treated as replication cardinality.

## Test documentation

- `docs/OSWAPSACW_CHATGPT_PLUGIN_TESTING.md` defines the executable semantic contract.
- `docs/OSWAPSACW_CHATGPT_PLUGIN_TEST_VECTORS.txt` provides plain-text accessibility-friendly test vectors.

The current contract treats `twin` as cardinality and `joker` as policy. Publisher principals are authorization subjects rather than assumptions about a person's singular identity, and credential compromise is handled independently from project or principal attribution.

## Tech-Assisted Workflows

`docs/OSWAP_TECH_ASSISTED_WORKFLOWS.md` defines the OSWAP model for auditable human-authorized workflows that combine local execution, provider integrations, LLM tool use, and independent verification.

Repository provisioning and cross-provider publication are documented as canonical examples. Tool progress is treated as activity evidence rather than completion proof, and partial execution must remain visible in the audit record.

## LLM epistemic guardrail

`docs/OSWAP_LLM_EPISTEMIC_GUARDRAIL.md` defines the proposed OSWAP epistemic guardrail for LLM-assisted software development.

Its central rule is that generative output is not promoted into verified project knowledge merely because a model produced it, repeated it, or another model agreed with it. Material claims should be grounded in independently inspectable repository evidence, authoritative documentation, deterministic tests, runtime observation, provider-backed state, or a documented combination of those sources.

The proposed feedback loop separates human intent, bounded delegation, model analysis, independent critique, deterministic verification, human authorization, execution, post-operation verification, and provenance. Model consensus is treated as a critique signal rather than proof.

The optional `epistemic` object in `plugins/oswapsacw/schemas/audit-record.schema.json` records claims, evidence classes, deterministic checks, evaluator independence, human decisions, and residual uncertainty without requiring disclosure of hidden model chain-of-thought.

## LLM-Assisted Console Parser

`docs/OSWAP_LLM_ASSISTED_CONSOLE_PARSER.md` defines the planned OSWAP parser profile for multilingual, typo-tolerant, human-readable console input. The LLM layer produces a typed parse candidate only; deterministic OSWAP validation, effect classification, consent, provider authorization, and independent verification remain mandatory before any mutation.

The profile also records the planned explicit `@Tool` invocation convention, context provenance, experimental high-level intent envelopes, and the rule that raw user or model text must never be passed to arbitrary shell evaluation.
