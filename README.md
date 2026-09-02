# OSWAPSACW ChatGPT Plugin

SPDX-License-Identifier: Apache-2.0

Experimental plugin for the Open-Source World Access Project (OSWAP) Standard for Auditable Code Workflows.

Canonical OSWAP replication vocabulary:

```text
oswap upload twin=N
oswap download twin=N
```

The plugin packages a reusable OSWAPSACW workflow skill, optional GitHub and GitLab connected-app bindings, and Remote Desktop Commander as a hosted MCP execution backend.

## Design boundary

OSWAPSACW orchestrates capabilities; it does not merge credentials or bypass provider permissions. GitHub, GitLab, and Remote Desktop Commander retain their own authorization and access controls.

Remote Desktop Commander is used for authorized local filesystem and terminal work. Because its tools execute with the paired machine user's permissions, consequential work remains preview-first and human-authorized.

## Repository layout

```text
.agents/plugins/marketplace.json
plugins/oswapsacw/.codex-plugin/plugin.json
plugins/oswapsacw/.app.json
plugins/oswapsacw/.mcp.json
plugins/oswapsacw/skills/oswapsacw/SKILL.md
plugins/oswapsacw/schemas/audit-record.schema.json
plugins/oswapsacw/tests/Test-OSWAPSACW.ps1
```

## Local validation

```powershell
powershell -NoProfile -File .\plugins\oswapsacw\tests\Test-OSWAPSACW.ps1
```

This prototype does not itself implement repository transport. It standardizes ChatGPT/Codex orchestration around OSWAP semantics and delegates actual repository/local operations to authorized tools.

`oswap download twin=N` is defined here as the canonical retrieval/reconstruction vocabulary; the existing OSWAP 0.2 PowerShell dispatcher may require a separate runtime implementation before that command can execute directly outside the plugin workflow.
