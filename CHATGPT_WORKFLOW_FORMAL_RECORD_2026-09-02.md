# OSWAP ChatGPT Software Development Workflow — Formal Record

Date: 2026-09-02
Project: Open-Source World Access Project (OSWAP)
Component: OSWAPSACW ChatGPT Plugin
Status: Experimental open-source development architecture

## Purpose

This record documents the established ChatGPT-assisted software-development workflow currently used for OSWAP and the planned development of an open-source ChatGPT software-development Plugin based on officially supported OpenAI Plugin, Apps SDK, skill, and MCP mechanisms.

The project must not imply that OpenAI has created, certified, endorsed, or specifically supported OSWAPSACW unless OpenAI separately provides written authorization for that claim. The intended description is: an open-source Plugin built for OpenAI-supported ChatGPT development mechanisms.

OSWAP development began on 2026-08-31. By 2026-09-02, the workflow had evolved into a multi-tool, auditable development pattern using ChatGPT as the orchestration interface.

## Established workflow

The current workflow combines three principal capability classes:

1. GitHub connected tooling for authoritative GitHub repository inspection and supported repository actions.
2. GitLab connected tooling for authoritative GitLab repository inspection and supported repository actions.
3. Remote Desktop Commander for authorized local filesystem, terminal, process, build, and test operations on the paired development machine.

Provider-native repository tools are preferred when they can perform the requested action directly. Remote Desktop Commander is the local execution and fallback surface when repository plugins cannot perform necessary filesystem, terminal, or build operations.

## OSWAP syntax boundary

Canonical transfer vocabulary currently recorded by the Plugin:

```text
oswap upload twin=N
oswap download twin=N
```

`twin` is cardinality: how many independently selected copies or sources participate.

`joker` is policy: how eligible copies or sources are selected or used.

These are separate control dimensions. Future joker expressions must not be silently interpreted as twin replication counts.

## Informed-consent architecture

OSWAPSACW treats consent as an executable precondition for state-changing work rather than a documentation-only promise.

Each proposed action is classified as one of:

- `read_only`: inspection without mutation.
- `local_write`: mutation of files, processes, installations, configuration, or other local state.
- `remote_write`: mutation of repository, service, account, deployment, or other external state.
- `destructive`: deletion, overwrite, force-update, history rewrite, revocation, or another difficult-to-reverse operation.
Before any write, the workflow must disclose:

- what will change;
- the concrete targets;
- material side effects;
- relevant data exposure;
- whether the action is reversible;
- the rollback plan when one exists; and
- the exact authorization scope.

Every write requires an operation-scoped authorization state of `approved`. Missing, denied, or cancelled consent fails closed. A previous approval for a different action must not be treated as blanket permission for a later remote or destructive action.

The consent architecture is implemented by:

- `plugins/oswapsacw/schemas/consent-envelope.schema.json`
- `plugins/oswapsacw/scripts/Assert-OSWAPSACWConsent.ps1`
- action classification emitted by `Resolve-OSWAPSACWCommand.ps1`
- conformance tests covering approved, denied, and missing consent states
- audit-schema fields that separate proposal, authorization, execution, validation, and verification

Host-level ChatGPT permission prompts remain authoritative. OSWAPSACW adds a stricter application-level contract; it does not bypass OpenAI, provider, workspace, operating-system, or account permission controls.

## Relationship to current OpenAI development mechanisms

As of 2026-09-02, OpenAI documents Plugins as the primary discovery layer for workflow capabilities across ChatGPT and Codex. A Plugin may package apps and skills, while Apps SDK provides the open-source, MCP-based integration layer for app logic and interfaces.

This makes OSWAPSACW's intended architecture technically aligned with the current OpenAI extension model: a Plugin can package the workflow skill, declare connected apps, and use MCP-backed execution services without collapsing their separate permission boundaries.

OpenAI's current app-permission model also distinguishes read access from write actions and may require confirmation before consequential changes. OSWAPSACW deliberately mirrors and strengthens this model by requiring a structured consent envelope for every mutation.

Official references consulted for this record:

- https://help.openai.com/en/articles/11487775
- https://help.openai.com/en/articles/12515353
- https://help.openai.com/en/articles/12584461
- https://openai.com/policies/developer-apps-terms/

## Planned Plugin goals

The planned open-source Plugin should remain auditable, accessible, and provider-aware. Its intended responsibilities are workflow orchestration, deterministic OSWAP command interpretation, consent preflight, provenance logging, validation, and post-action verification.

It should not become a credential broker, silently widen permissions, bypass ChatGPT confirmation controls, or treat local machine access as authority over unrelated remote systems.

## Fallback and verification rules

If one provider integration is unavailable, the workflow may fall back to another authorized execution surface only when that surface can perform the requested task without bypassing the unavailable provider's permissions.

Fallback is not permission escalation. A local terminal may prepare commits, tests, patches, or artifacts, but remote publication still requires the relevant remote authorization and consent boundary.

Every consequential workflow should distinguish:

1. inspected source state;
2. proposed change;
3. consent and authorization;
4. actual execution;
5. validation; and
6. independent verification.

A tool call is not treated as proof that an intended effect occurred. Verification is a separate recorded phase.

## Accessibility objective

The Plugin should expose concise, readable action summaries before consent prompts, avoid dense visual clutter, use clear action labels, and make risk, targets, and rollback information understandable without requiring the user to inspect raw command syntax.

Accessibility is part of the workflow contract rather than an optional presentation layer: informed consent is weaker when the proposed effect cannot be read or understood comfortably.

## Current implementation status

The local prototype has been advanced to version 0.2.0 architecture with a consent envelope schema and deterministic PowerShell consent gate. Local conformance tests pass for approved, denied, and missing consent states.

No remote publication is authorized by this formal record alone. Repository pushes, releases, or external deployment remain separate `remote_write` operations requiring their own scoped approval.
