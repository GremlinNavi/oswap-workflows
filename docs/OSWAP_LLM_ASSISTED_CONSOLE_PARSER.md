# OSWAP LLM-Assisted Console Parser

SPDX-License-Identifier: Apache-2.0

## Status

This document defines a design profile for an OSWAP console parser that may use a large language model (LLM) to normalize human-readable input into a typed OSWAP operation plan. It does not make raw LLM output executable and does not replace the deterministic OSWAP grammar, consent layer, provider authorization, or verification requirements.

The current OSWAPSACW reference resolver already implements deterministic parsing for canonical transfer forms such as:

```text
oswap upload twin=N
oswap download twin=N
```

The LLM-assisted parser described here is an additional front-end layer for accessibility, multilingual interaction, typo tolerance, and higher-level intent expression.

## Design goal

The parser should bridge flexible human expression and deterministic system execution without collapsing the boundary between the two.

```text
human / localized console input
  -> lossless input capture
  -> deterministic canonical-grammar check
  -> optional LLM intent normalization
  -> typed parse candidate
  -> deterministic schema + policy validation
  -> effect classification
  -> consent / authorization gate
  -> execution adapter
  -> independent verification
  -> provenance record
```

The LLM may help interpret language. It MUST NOT become the authority that decides whether a command is valid, authorized, or safe to execute.

## Core rule: interpretation is not execution

A conforming implementation MUST preserve these boundaries:

1. Raw console text is data, not shell code.
2. LLM output is a parse proposal, not an executable command.
3. The parse proposal must validate against an OSWAP-owned schema or grammar.
4. Any requested capability must resolve to an explicitly registered adapter or tool.
5. Writes must pass the OSWAP consent gate and the provider or operating-system authorization boundary.
6. Execution results must be independently verified before the workflow is represented as complete.

Implementations MUST NOT pass user input or LLM output to `Invoke-Expression`, shell `eval`, or an equivalent arbitrary-code evaluator.

## Parser modes

### 1. Canonical mode

If input already matches a deterministic OSWAP grammar, the parser should use that grammar directly and skip LLM interpretation.

Example:

```text
oswap upload twin=(4+3)/2
```

The arithmetic expression remains subject to the restricted OSWAP arithmetic grammar and deterministic evaluator.

### 2. Assisted mode

If input is human-readable but not canonical, an LLM may propose a normalized operation.

Example human input:

```text
upload three mirrored copies of this repository
```

Possible normalized candidate:

```json
{
  "operation": "repository.transfer",
  "direction": "upload",
  "replication_expression": "3",
  "effect": "remote_write"
}
```

The JSON is still only a candidate. A deterministic validator must confirm that the operation, fields, values, target, and requested adapter are permitted.

### 3. Explain-only mode

The parser may interpret a command for explanation without authorizing execution.

Example:

```text
explain oswap upload twin=(9/3)
```

The result may describe the meaning of the command while keeping `execution_requested=false`.

## Proposed typed parse candidate

An implementation should preserve enough information for auditing and deterministic validation.

```json
{
  "parser_profile": "oswap-llm-assisted-console/v1",
  "raw_input": "...",
  "normalized_locale": "en-CA",
  "parse_path": "canonical|llm_assisted|explain_only",
  "operation": "...",
  "arguments": {},
  "requested_tools": [],
  "effect": "read_only|local_write|remote_write|destructive",
  "execution_requested": false,
  "confidence": 0.0,
  "ambiguities": [],
  "context_sources": [],
  "candidate_only": true
}
```

`candidate_only` should remain true until deterministic validation succeeds. Validation success does not itself authorize execution.

## Context and memory

LLM interpretation can change when conversational context, retrieved documents, saved preferences, locale, or tool availability changes. OSWAP therefore treats operative context as provenance-bearing input.

When context materially affects parsing, the parser SHOULD record the relevant context category or source identifier. It SHOULD NOT silently convert remembered or retrieved information into authorization.

Examples of context that may affect interpretation include:

- the active repository or working directory;
- the selected human language or locale;
- a previously selected provider;
- a retrieved OSWAP syntax reference;
- available tool or plugin names;
- an explicit user preference for an output format.

Context may resolve meaning. Context must not manufacture consent.

## Multilingual and accessibility behavior

The assisted layer may accept ordinary literary grammar from the active human language and normalize it into OSWAP's language-neutral typed representation.

This enables an implementation to be tolerant of:

- spelling mistakes and dyslexic transpositions;
- punctuation variation;
- speech-to-text artifacts;
- localized terminology;
- common slang or informal console wording;
- mixed natural-language and canonical OSWAP fragments.

Tolerance at the interpretation layer MUST NOT weaken deterministic validation at the execution layer.

For accessibility, implementations SHOULD preserve the original input alongside any normalized form, provide a plain-language preview of the resolved operation, and make cancellation a normal result rather than an error condition.

## Experimental high-level command envelopes

OSWAP research may use readable colon-delimited command envelopes for high-level intent expression, for example:

```text
Joker:to:Search:Meaning:"factual accuracy"
```

Such forms are not automatically equivalent to shell commands or provider calls. An implementation may parse the fields into a structured intent object, but it must still resolve the requested operation through an allowlisted capability and effect classifier.

A parser should preserve unknown fields rather than inventing semantics for them.

## Explicit plugin and tool invocation

For the planned OSWAP console profile, a leading `@` is reserved as the visible marker for an explicit plugin, tool, or connected-service invocation.

Examples:

```text
@GitHub inspect repository state
@GitLab compare mirror state
@Web search OSWAP accessibility precedents
```

The presence of `@Name` identifies a requested capability target; it does not guarantee that the capability exists, is connected, or is authorized. The parser must resolve the name against the active tool registry.

Text that merely contains words such as `GitHub`, `search`, or `web` without the explicit invocation marker should not be silently promoted into an external tool call unless another canonical OSWAP rule explicitly requires that behavior.

## Comments and literal preservation

The planned console profile may use square brackets for human-readable comment or annotation text where the surrounding grammar permits it.

Example:

```text
oswap upload twin=3 [publish three complete copies]
```

Comments are non-executable metadata. A deterministic lexer must distinguish comment text from literals and structured arguments so that brackets inside quoted data are not discarded accidentally.

The exact lexical rules for comments should be versioned before they become normative syntax.

## Ambiguity handling

The parser must fail closed when multiple materially different executable interpretations remain plausible.

For read-only explanation, the implementation may show candidate interpretations. For mutation, unresolved ambiguity must prevent execution.

Examples of material ambiguity include:

- an unspecified repository when multiple repositories are active;
- `publish` when public visibility and Git push are both plausible;
- a tool nickname that maps to multiple registered capabilities;
- a replication request whose cardinality cannot be resolved deterministically.

Confidence scores are advisory diagnostics. A high model confidence score is not a substitute for deterministic validation.

## Effect classification

Every validated operation should be classified before execution:

```text
read_only
local_write
remote_write
destructive
```

The parser may suggest an effect class, but the authoritative class must come from OSWAP policy or adapter metadata.

Examples:

- explain a command -> `read_only`
- write a local generated file -> `local_write`
- push a repository -> `remote_write`
- delete or history-rewrite operation -> `destructive`

Unknown effects fail closed.

## Tool resolution

An LLM-assisted parser should never fabricate a capability because its name sounds plausible. Requested tools must resolve against a runtime registry that records, at minimum:

- stable tool identifier;
- human-readable name;
- supported operations;
- effect classification rules;
- provider or host boundary;
- authorization requirements;
- input and output schemas.

A parser may report that a requested tool is unavailable. It must not pretend that the tool ran.

## Audit record

A material parser event SHOULD record:

- timestamp;
- raw input hash and, when appropriate, raw input text;
- parser profile and version;
- locale;
- canonical or assisted parse path;
- model/provider identifier when an LLM is used;
- context sources that materially affected the parse;
- typed candidate;
- validation result;
- effect class;
- consent result;
- selected adapter/tool;
- execution result;
- independent verification result;
- unresolved ambiguity or partial-completion state.

Sensitive data should be minimized or redacted in audit output according to the applicable OSWAP privacy policy.

## Security properties

A conforming implementation should preserve the following properties:

- no arbitrary shell evaluation of parser text;
- no automatic execution of generated code;
- no authorization expansion through model inference;
- no silent tool invocation based only on semantic similarity;
- no mutation while material ambiguity remains unresolved;
- deterministic validation after LLM normalization;
- explicit effect classification before mutation;
- fail-closed consent handling;
- independent post-execution verification;
- provenance for context-dependent interpretation.

## Relationship to current OSWAPSACW code

`plugins/oswapsacw/scripts/Resolve-OSWAPSACWCommand.ps1` is a deterministic resolver for canonical `twin` transfer syntax. It validates the input character set, normalizes the command, classifies upload as `remote_write` and download as `local_write`, and marks arbitrary shell evaluation as false.

The LLM-assisted parser should sit before that class of deterministic resolver, not replace it.

A future implementation may introduce a dedicated command such as:

```text
oswap parse --assist <TEXT>
```

or expose assisted parsing transparently at an interactive console, provided the resulting operation is previewed and validated before execution.

## Non-goals

This design does not claim that an LLM makes arbitrary natural language deterministic. It does not guarantee that two models will produce the same parse candidate. It does not treat conversational memory as authorization. It does not make OSWAP a shell-code evaluator, and it does not bypass provider permissions or host security controls.

The objective is narrower: use probabilistic language understanding to improve the human-facing input surface while keeping the executable boundary deterministic, auditable, and consent-gated.
