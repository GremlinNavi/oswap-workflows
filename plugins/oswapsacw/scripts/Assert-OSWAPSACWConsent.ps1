# SPDX-License-Identifier: Apache-2.0
#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$ConsentPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $ConsentPath -PathType Leaf)) {
    throw "Consent envelope not found: $ConsentPath"
}

$consent = Get-Content -LiteralPath $ConsentPath -Raw | ConvertFrom-Json
$required = @('operation_id','action_class','summary','targets','side_effects','authorization')
foreach ($name in $required) {
    if ($consent.PSObject.Properties.Name -notcontains $name) {
        throw "Consent envelope missing required field: $name"
    }
}

$classes = @('read_only','local_write','remote_write','destructive')
if ($classes -notcontains [string]$consent.action_class) {
    throw "Unknown action_class: $($consent.action_class)"
}

$isWrite = $consent.action_class -ne 'read_only'
$authorization = $consent.authorization
if ($authorization.PSObject.Properties.Name -notcontains 'required' -or
    $authorization.PSObject.Properties.Name -notcontains 'status' -or
    $authorization.PSObject.Properties.Name -notcontains 'scope') {
    throw 'Consent authorization object is incomplete.'
}

if ($isWrite -and -not [bool]$authorization.required) {
    throw 'CONSENT_INVALID: write actions must declare authorization.required=true.'
}
if (-not $isWrite -and [bool]$authorization.required) {
    throw 'CONSENT_INVALID: read_only actions must declare authorization.required=false.'
}

if ($isWrite) {
    if (@($consent.targets).Count -lt 1) {
        throw 'CONSENT_INVALID: write actions must identify at least one target.'
    }
    if (@($consent.side_effects).Count -lt 1) {
        throw 'CONSENT_INVALID: write actions must disclose at least one side effect.'
    }
    if ([string]::IsNullOrWhiteSpace([string]$authorization.scope)) {
        throw 'CONSENT_INVALID: write actions require an authorization scope.'
    }
    if ([string]$authorization.status -ne 'approved') {
        throw "CONSENT_DENIED: write action status is '$($authorization.status)'."
    }
}

if (-not $isWrite) {
    $readStatuses = @('not_required','approved')
    if ($readStatuses -notcontains [string]$authorization.status) {
        throw "CONSENT_DENIED: read action status is '$($authorization.status)'."
    }
}

if ($consent.PSObject.Properties.Name -contains 'reversible' -and
    [bool]$consent.reversible -and
    ($consent.PSObject.Properties.Name -notcontains 'rollback_plan' -or
     [string]::IsNullOrWhiteSpace([string]$consent.rollback_plan))) {
    throw 'CONSENT_INVALID: reversible actions must provide a rollback_plan.'
}

[pscustomobject][ordered]@{
    standard = 'OSWAPSACW'
    operation_id = [string]$consent.operation_id
    action_class = [string]$consent.action_class
    consent_required = $isWrite
    authorization_status = [string]$authorization.status
    authorization_scope = [string]$authorization.scope
    decision = 'allow'
    expires_after_operation = if ($authorization.PSObject.Properties.Name -contains 'expires_after_operation') { [bool]$authorization.expires_after_operation } else { $true }
} | ConvertTo-Json
