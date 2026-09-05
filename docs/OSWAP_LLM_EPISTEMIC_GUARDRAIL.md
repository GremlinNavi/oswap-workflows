# OSWAP LLM Epistemic Guardrail

SPDX-License-Identifier: Apache-2.0

## Purpose

The OSWAP LLM Epistemic Guardrail defines a proposed standard for auditable software development in which outputs from large language models are treated as claims, proposals, or hypotheses until they are supported by independently inspectable evidence.

The guardrail is intended to reduce epistemic error propagation in LLM-assisted development. It separates what a model says from what the development record is justified in treating as established.

This document is model-agnostic. It does not require any particular LLM provider, agent framework, IDE, repository host, or operating system.

## Core rule

```text
LLM assertion != verified fact
LLM-generated code != verified implementation
LLM agreement != independent proof
```

An LLM-derived software-development assertion MUST NOT be treated as verified solely because a model generated it, repeated it, or agreed with another model.

Confidence SHOULD increase because independent evidence accumulates, not because generative output is repeated.

## Canonical epistemic loop

```text
human intent
  -> bounded task definition
  -> evidence acquisition
  -> LLM proposal or analysis
  -> independent critique
  -> deterministic verification where available
  -> human authorization / acceptance decision
  -> execution
  -> post-execution verification
  -> provenance record
  -> next bounded task
```

The loop MAY repeat as many times as needed, but each iteration SHOULD preserve the distinction between claim, evidence, decision, and observed result.

A development workflow MUST NOT silently convert an earlier model inference into accepted project state merely because later prompts inherit that inference as context.

## Bounded delegation

LLM-assisted work SHOULD be delegated as explicit, reviewable units rather than indefinite authority.

A bounded task SHOULD identify, where applicable:

1. The intended objective.
2. The target repository, file set, service, or resource.
3. The allowed operation class.
4. Material constraints or prohibited side effects.
5. The expected stopping condition.
6. The verification method.

Example:

```text
objective: replace stale PS-twin references with OSWAP-twin
scope: GremlinNavi/OSWAP-twin documentation
allowed mutation: textual rename only
termination: stop after the requested cleanup
verification: re-search repository for stale references
```

This structure allows an AI system to execute useful work while preserving strict human control over scope expansion.

## Evidence classes

OSWAP distinguishes model output from evidence used to justify a software-development conclusion.

### E0 - Generative assertion

Examples:

- an LLM says a file exists;
- an LLM says a patch compiles;
- an LLM says two branches are synchronized;
- an LLM says an API behaves in a particular way.

E0 is a hypothesis or report. It is not sufficient verification by itself.

### E1 - Inspectable documentary or repository evidence

Examples:

- repository file contents;
- version-control history;
- authoritative documentation;
- dependency manifests;
- provider metadata.

E1 supports a claim when the evidence is directly relevant and its provenance is recorded.

### E2 - Deterministic analysis or test evidence

Examples:

- compiler or interpreter output;
- unit or integration tests;
- static analysis;
- schema validation;
- checksum comparison;
- deterministic parser results.

E2 is preferred when the claim can be tested mechanically.

### E3 - Runtime or provider-state observation

Examples:

- observed program behavior;
- successful deployment state;
- exact remote commit equality;
- filesystem state after mutation;
- provider API confirmation.

E3 is preferred for claims about the actual post-operation state of a system.

### Human decision

Human approval is an authorization or acceptance decision, not a substitute for technical evidence. A human MAY accept residual uncertainty, but the unresolved uncertainty SHOULD remain visible in the audit record.

## Model consensus is not evidence

Agreement between multiple LLMs MAY be useful as a critique signal, but consensus MUST NOT be represented as independent verification unless the underlying evidence is independently established.

Two models can share training influences, prompt assumptions, retrieved context, or correlated failure modes. Therefore:

```text
model A agrees with model B
```

is weaker than:

```text
model A proposes claim
model B critiques claim
repository evidence supports claim
build/test result supports claim
human accepts result
```

An evaluator model SHOULD attempt to falsify or challenge the generator's material claims rather than merely restating them.

## Generator-evaluator-verifier separation

An OSWAP-compatible LLM workflow MAY use one or more models in different roles:

```text
generator -> proposes implementation or explanation
evaluator -> searches for errors, unsupported assumptions, and scope drift
verifier  -> obtains deterministic or provider-backed evidence
human     -> authorizes consequential action and accepts or rejects the result
```

These roles MAY be performed by different models, the same model in separate passes, deterministic tools, or humans. When the same model performs multiple roles, the audit record SHOULD NOT describe those passes as independent evidence.

Model diversity can improve critique coverage, but model diversity alone does not satisfy verification.

## Deterministic checks take precedence where available

When a material claim can be verified deterministically, the workflow SHOULD prefer the deterministic check over model judgment.

Examples:

```text
claim: code compiles
preferred check: compiler/build result

claim: tests pass
preferred check: test runner result

claim: remote repository matches local HEAD
preferred check: exact commit or content comparison

claim: schema is valid
preferred check: schema validator

claim: stale identifier is gone
preferred check: repository search
```

LLMs remain useful for interpretation, diagnosis, synthesis, and proposing corrections, but SHOULD NOT replace stronger available evidence.

## Failure and uncertainty handling

An epistemic guardrail MUST preserve negative and incomplete outcomes.

The workflow MUST NOT transform any of the following into success by inference:

- a tool progress message;
- an attempted command;
- a model statement that an operation probably succeeded;
- partial provider completion;
- a failed verification step;
- missing evidence.

Acceptable auditable outcomes include:

```text
verified
rejected
partially verified
unverified
inconclusive
blocked by authorization
blocked by unavailable capability
```

Uncertainty is a valid recorded state.

## Feedback-loop integrity

The purpose of the feedback loop is not to make a model repeatedly endorse its own output. The purpose is to expose generated claims to criticism and evidence before those claims become accepted development state.

A conforming loop SHOULD resist recursive error laundering:

```text
incorrect model assumption
  -> inherited context
  -> repeated model agreement
  -> false confidence
```

Instead, material inherited assumptions SHOULD be re-grounded when they affect consequential decisions.

## Human oversight

For OSWAP Standards for Auditable Software Development, consequential mutations SHOULD remain under explicit human authorization unless a separately documented profile defines a narrower pre-authorized automation boundary.

Human oversight includes the authority to:

- restrict scope;
- require additional evidence;
- reject a model conclusion;
- stop execution;
- choose a different tool or model;
- accept a documented residual uncertainty;
- authorize the next bounded task.

The existence of an AI recommendation MUST NOT itself expand authorization.

## Minimum epistemic audit record

For material LLM-assisted development steps, an OSWAP audit record SHOULD capture, where applicable:

- declared human intent;
- bounded task scope;
- target resource;
- model or tool identity when known;
- observable input or instruction relevant to the decision;
- material model claims or proposed changes;
- evidence sources consulted;
- deterministic checks performed;
- execution result;
- post-execution verification result;
- human authorization or acceptance decision;
- unresolved uncertainty or verification gaps;
- resulting commit, object identifier, checksum, or provider-state identifier;
- timestamp and provenance links.

OSWAP does not require storage or disclosure of a model's hidden chain-of-thought. Auditability concerns observable instructions, claims, evidence, actions, decisions, and results.

## Relationship to OSWAP Tech-Assisted Workflows

This epistemic guardrail is a specialized layer within OSWAP Tech-Assisted Workflows.

Tech-Assisted Workflows define how human-authorized tools inspect, execute, and verify operations. The Epistemic Guardrail defines what evidence is required before LLM-derived claims are promoted into accepted software-development state.

Together:

```text
human control
  + bounded delegation
  + model-agnostic critique
  + independent evidence
  + deterministic verification
  + post-operation observation
  + provenance
  = auditable LLM-assisted development
```

## Informative standards alignment

This proposal is informed by, but is not represented as certified by or formally compliant with, external standards and guidance including:

- NIST SP 800-218, Secure Software Development Framework (SSDF) Version 1.1: https://csrc.nist.gov/pubs/sp/800/218/final
- NIST SP 800-218A, Secure Software Development Practices for Generative AI and Dual-Use Foundation Models: An SSDF Community Profile: https://csrc.nist.gov/pubs/sp/800/218/a/final
- NIST AI 600-1, Artificial Intelligence Risk Management Framework: Generative Artificial Intelligence Profile: https://www.nist.gov/publications/artificial-intelligence-risk-management-framework-generative-artificial-intelligence

NIST SP 800-218 describes a common secure-software-development framework. SP 800-218A augments that framework with AI-specific development practices, and NIST AI 600-1 addresses risk management for generative AI across the AI lifecycle.

OSWAP's proposed contribution is narrower: an implementation-oriented epistemic guardrail for LLM-assisted software-development workflows, emphasizing the separation of generative claims from independently auditable evidence.
