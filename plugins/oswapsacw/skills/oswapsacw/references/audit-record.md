# OSWAPSACW audit record

Use this structure when a durable or formal audit record is requested.

```yaml
oswapsacw_version: 0.1.0
operation_id: <unique local identifier>
timestamp_utc: <ISO-8601>
request:
  summary: <human request>
  canonical_operation: <OSWAP operation or non-OSWAP workflow>
proposal:
  source_state: <branch/commit/files or other source state>
  intended_changes: []
  destinations_or_sources: []
  material_warnings: []
authorization:
  required: true|false
  status: not_required|approved|denied|cancelled
  scope: <what was authorized>
execution:
  tools_used: []
  actions: []
  changed_artifacts: []
validation:
  tests: []
  results: []
verification:
  local_state: <verified result>
  remote_state: []
  hashes_or_ids: []
errors: []
unresolved_gaps: []
```

Never record passwords, tokens, private keys, authentication headers, or sensitive command-line values in the audit record.

Distinguish proposal from authorization and authorization from execution. A proposed action is not evidence that it occurred. A tool call is not evidence that its intended effect succeeded. Verification must be recorded separately.

For `oswap upload twin=N`, record the resolved replication factor and selected destinations. For `oswap download twin=N`, record the resolved factor, selected source twins, local destination, and integrity/reconstruction verification when available.
