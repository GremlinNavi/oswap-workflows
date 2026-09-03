# OSWAPSACW audit record

Use this structure when a durable or formal audit record is requested.

```yaml
oswapsacw_version: 0.2.0
operation_id: <unique local identifier>
timestamp_utc: <ISO-8601>
request:
  summary: <human request>
  canonical_operation: <OSWAP operation or non-OSWAP workflow>
  action_class: read_only|local_write|remote_write|destructive
proposal:
  source_state: <branch/commit/files or other source state>
  targets: []
  intended_changes: []
  side_effects: []
  data_exposure: []
  reversible: true|false
  rollback_plan: <rollback method or why unavailable>
  destinations_or_sources: []
authorization:
  required: true|false
  status: not_required|approved|denied|cancelled|missing
  scope: <what was authorized>
  expires_after_operation: true|false
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

For every write, the audit record should correspond to an informed-consent envelope that identifies targets, effects, exposure, reversibility, rollback, and authorization scope. Missing or denied authorization must be recorded as a blocked operation, not silently converted into approval.

For `oswap upload twin=N`, record the resolved replication factor and selected destinations. For `oswap download twin=N`, record the resolved factor, selected source twins, local destination, and integrity/reconstruction verification when available.
