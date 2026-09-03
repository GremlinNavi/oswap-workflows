# SPDX-License-Identifier: Apache-2.0
#requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Command
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$text = ($Command -replace '\s+', ' ').Trim()

if ($text -notmatch '^oswap\s+(upload|download)\s+twin=(.+)$') {
    throw 'Expected canonical syntax: oswap upload twin=N or oswap download twin=N'
}

$verb = $Matches[1].ToLowerInvariant()
$expression = ($Matches[2] -replace '\s+', '')
if ([string]::IsNullOrWhiteSpace($expression)) { throw 'Twin expression is empty.' }
if ($expression -notmatch '^[0-9+\-*/^().]+$') {
    throw 'Twin expression contains characters outside the OSWAP arithmetic grammar.'
}

$actionClass = if ($verb -eq 'upload') { 'remote_write' } else { 'local_write' }
$transportOperation = if ($verb -eq 'upload') { 'publish-replicas' } else { 'retrieve-replicas' }

$result = [ordered]@{
    standard = 'OSWAPSACW'
    canonical_command = "oswap $verb twin=$expression"
    verb = $verb
    replication_expression = $expression
    transport_operation = $transportOperation
    action_class = $actionClass
    consent_required = $true
    requires_remote_write_authorization = ($verb -eq 'upload')
    may_modify_local_state = ($verb -eq 'download')
    consent_gate = 'scripts/Assert-OSWAPSACWConsent.ps1'
    arbitrary_shell_evaluation = $false
}

[pscustomobject]$result | ConvertTo-Json
