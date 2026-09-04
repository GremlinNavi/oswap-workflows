# OSWAP Tech-Assisted Workflows

SPDX-License-Identifier: Apache-2.0

## Purpose

OSWAP Tech-Assisted Workflows define auditable human-authorized workflows in which one or more software tools help inspect, prepare, execute, or verify a digital operation.

A Tech-Assisted Workflow is not permission for autonomous mutation. Human intent, provider authorization, tool capability, execution state, and verification remain distinct parts of the record.

The workflow model is deliberately tool- and model-agnostic. An OSWAP-compatible implementation may use a local terminal, remote desktop bridge, Git provider integration, LLM tool caller, CI system, or another authorized interface, provided that the resulting operation can be represented and independently audited.

## Canonical workflow stages

```text
human intent
  -> capability discovery
  -> target resolution
  -> authorization / consent gate
  -> execution
  -> provider or filesystem result
  -> independent verification
  -> provenance record
```

Each stage SHOULD be observable separately. A progress message such as `Fetching Repository README Content` or `Creating repository` is an activity description, not proof that the activity completed.

## Provider and execution boundaries

OSWAP does not merge credentials or collapse provider trust boundaries. GitHub, GitLab, the local operating system, Remote Desktop Commander, ChatGPT integrations, and other services retain their own authentication, authorization, and policy controls.

Tool substitution is permitted when semantics remain equivalent and the substitution is recorded. If one tool can inspect a provider but cannot perform the required mutation, the workflow MAY fall back to another authorized tool rather than fabricating success.
## Repository provisioning workflow

Creating or mirroring an OSWAP code repository across Git hosting providers is a canonical Tech-Assisted Workflow.

Example target set:

```text
local source: oswapsacw-chatgpt-plugin
provider A: GitHub / GremlinNavi
provider B: GitLab / GremlinNavi-group
```

The workflow SHOULD:

1. Inspect the local Git state and identify the intended source commit.
2. Confirm the authenticated provider identity and the intended namespace.
3. Check whether the target repository already exists before attempting creation.
4. Disclose that repository creation is a remote write and identify the target provider and repository slug.
5. Create only the explicitly authorized repository or repositories.
6. Configure remotes without exposing or copying provider credentials into repository files.
7. Push the intended branch without force-pushing or rewriting history unless separately authorized.
8. Verify the resulting provider repository, default branch, and commit state.
9. Record any partial success, provider-specific limitation, or unresolved verification gap.

A failed or unavailable provider action MUST NOT be represented as completed. Partial completion is a valid auditable outcome.

## Multi-tool orchestration

An OSWAP workflow MAY combine multiple tools when each tool is used within its actual capability boundary. For example, a local execution bridge may inspect repository state and invoke Git commands, while a provider-native integration may inspect remote project metadata or perform provider-specific operations.

The orchestration layer SHOULD record which tool performed each material action rather than describing the entire sequence as if it were performed by a single agent.
## Recorded example: 2026-09-03 repository provisioning preflight

During an authorized OSWAP repository-provisioning workflow, the local `oswapsacw-chatgpt-plugin` repository was inspected through Remote Desktop Commander.

Observed state at preflight:

- Local branch: `main`.
- Local HEAD: `709a1ba` (`Document and test OSWAPSACW plugin semantics`).
- No remote was configured in the local repository at the time of inspection.
- GitHub CLI authentication resolved to the `GremlinNavi` account.
- The intended GitHub target `GremlinNavi/oswapsacw-chatgpt-plugin` was not present when checked.
- Existing sibling repositories demonstrated a GitLab namespace pattern under `GremlinNavi-group`.
- No GitLab project creation was represented as completed because the available provider path did not establish an authorized project-creation operation during this preflight.

This is an intentional example of auditable partial execution: capability discovery and target validation succeeded, while remote mutation remained incomplete. OSWAP documentation MUST preserve that distinction.

## Minimum audit fields

A Tech-Assisted Workflow record SHOULD capture, where applicable: human authorization subject, declared intent, tool or adapter identity, provider namespace, repository or resource identifier, operation class, pre-operation state, execution result, resulting commit or object identifier, timestamp, verification method, and unresolved gaps.

For Git publication, exact remote commit equality is preferred when the transport preserves Git history. Provider-generated equivalent commits require independent content verification and an explicit transport-equivalence record.

## Relationship to `joker` and `twin`

`twin` remains replication cardinality. `joker` remains a policy dimension. Tech-Assisted Workflows define how authorized tools carry out and record operations; they do not redefine either syntax term.

A future OSWAP parser MAY translate human-readable intent into a canonical operation plan, but the plan MUST remain subject to deterministic policy validation and provider authorization before mutation.