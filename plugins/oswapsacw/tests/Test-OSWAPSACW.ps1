# SPDX-License-Identifier: Apache-2.0
#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PluginRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $PluginRoot '.codex-plugin\plugin.json'
$AppsPath = Join-Path $PluginRoot '.app.json'
$McpPath = Join-Path $PluginRoot '.mcp.json'
$SkillPath = Join-Path $PluginRoot 'skills\oswapsacw\SKILL.md'
$AuditSchemaPath = Join-Path $PluginRoot 'schemas\audit-record.schema.json'
$ConsentSchemaPath = Join-Path $PluginRoot 'schemas\consent-envelope.schema.json'

$manifest = Get-Content -Raw $ManifestPath | ConvertFrom-Json
$apps = Get-Content -Raw $AppsPath | ConvertFrom-Json
$mcp = Get-Content -Raw $McpPath | ConvertFrom-Json
$auditSchema = Get-Content -Raw $AuditSchemaPath | ConvertFrom-Json
$consentSchema = Get-Content -Raw $ConsentSchemaPath | ConvertFrom-Json
$skill = Get-Content -Raw $SkillPath

if ($manifest.name -ne 'oswapsacw') { throw 'Plugin manifest name mismatch.' }
if ($manifest.apps -ne './.app.json') { throw 'Plugin app manifest is not declared.' }
if ($manifest.mcpServers -ne './.mcp.json') { throw 'Plugin MCP manifest is not declared.' }
if (-not $apps.apps.github.id) { throw 'GitHub app binding missing.' }
if (-not $apps.apps.gitlab.id) { throw 'GitLab app binding missing.' }
if ($mcp.mcpServers.'remote-desktop-commander'.url -ne 'https://mcp.desktopcommander.app/mcp') { throw 'Remote Desktop Commander endpoint mismatch.' }
if ($skill -notmatch [regex]::Escape('oswap upload twin=N')) { throw 'Canonical upload syntax missing.' }
if ($skill -notmatch [regex]::Escape('oswap download twin=N')) { throw 'Canonical download syntax missing.' }
if ($skill -notmatch 'Invoke-Expression') { throw 'Arithmetic safety rule missing.' }
if ($skill -notmatch 'Assert-OSWAPSACWConsent.ps1') { throw 'Consent gate rule missing.' }
if ($auditSchema.title -ne 'OSWAPSACW Audit Record') { throw 'Audit schema title mismatch.' }
if ($consentSchema.title -ne 'OSWAPSACW Informed Consent Envelope') { throw 'Consent schema title mismatch.' }

$defaults = @($manifest.interface.defaultPrompt)
if ($defaults.Count -gt 3) { throw 'Plugin has more than three default prompts.' }
foreach ($prompt in $defaults) {
    if ($prompt.Length -gt 128) { throw "Default prompt exceeds 128 characters: $prompt" }
}

$resolver = Join-Path $PluginRoot 'scripts\Resolve-OSWAPSACWCommand.ps1'
$upload = (& $resolver 'oswap upload twin=(9/3)' | ConvertFrom-Json)
$download = (& $resolver 'oswap download twin=2' | ConvertFrom-Json)
if ($upload.verb -ne 'upload' -or -not $upload.requires_remote_write_authorization) { throw 'Upload intent resolution failed.' }
if ($upload.action_class -ne 'remote_write' -or -not $upload.consent_required) { throw 'Upload consent classification failed.' }
if ($download.verb -ne 'download' -or -not $download.may_modify_local_state) { throw 'Download intent resolution failed.' }
if ($download.action_class -ne 'local_write' -or -not $download.consent_required) { throw 'Download consent classification failed.' }
Write-Output 'OSWAPSACW command intent resolution passed.'

$consentGate = Join-Path $PluginRoot 'scripts\Assert-OSWAPSACWConsent.ps1'
$tempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('oswapsacw-consent-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempRoot | Out-Null
try {
    $approvedPath = Join-Path $tempRoot 'approved.json'
    [ordered]@{
        operation_id = 'test-upload-1'
        action_class = 'remote_write'
        summary = 'Publish a test replica.'
        targets = @('example/repository')
        side_effects = @('Remote repository state changes.')
        data_exposure = @('Repository metadata is sent to the configured provider.')
        reversible = $true
        rollback_plan = 'Revert the authorized commit or restore the prior ref.'
        authorization = [ordered]@{
            required = $true
            status = 'approved'
            scope = 'One test publication operation only.'
            expires_after_operation = $true
        }
    } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $approvedPath -Encoding UTF8

    $decision = (& $consentGate $approvedPath | ConvertFrom-Json)
    if ($decision.decision -ne 'allow') { throw 'Approved consent envelope was not allowed.' }

    $deniedPath = Join-Path $tempRoot 'denied.json'
    $denied = Get-Content -Raw $approvedPath | ConvertFrom-Json
    $denied.authorization.status = 'denied'
    $denied | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $deniedPath -Encoding UTF8

    $blocked = $false
    try { & $consentGate $deniedPath | Out-Null } catch { $blocked = $_.Exception.Message -like 'CONSENT_DENIED:*' }
    if (-not $blocked) { throw 'Denied consent envelope did not fail closed.' }

    $missingPath = Join-Path $tempRoot 'missing.json'
    $missing = Get-Content -Raw $approvedPath | ConvertFrom-Json
    $missing.authorization.status = 'missing'
    $missing | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $missingPath -Encoding UTF8
    $blocked = $false
    try { & $consentGate $missingPath | Out-Null } catch { $blocked = $_.Exception.Message -like 'CONSENT_DENIED:*' }
    if (-not $blocked) { throw 'Missing consent did not fail closed.' }

    Write-Output 'OSWAPSACW informed-consent gate passed approved/denied/missing tests.'
}
finally {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
}

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PluginRoot)
$MarketplacePath = Join-Path $RepoRoot '.agents\plugins\marketplace.json'
$marketplace = Get-Content -Raw $MarketplacePath | ConvertFrom-Json
$entry = @($marketplace.plugins | Where-Object { $_.name -eq 'oswapsacw' })
if ($entry.Count -ne 1 -or $entry[0].source.path -ne './plugins/oswapsacw') { throw 'Marketplace OSWAPSACW entry is invalid.' }

Write-Output 'Marketplace entry validation passed.'
Write-Output 'OSWAPSACW plugin conformance checks passed.'
Write-Output 'Canonical: oswap upload twin=N'
Write-Output 'Canonical: oswap download twin=N'

$TestingDocPath = Join-Path $RepoRoot 'docs\OSWAPSACW_CHATGPT_PLUGIN_TESTING.md'
$VectorPath = Join-Path $RepoRoot 'docs\OSWAPSACW_CHATGPT_PLUGIN_TEST_VECTORS.txt'
$testingDoc = Get-Content -Raw $TestingDocPath
$vectors = Get-Content -Raw $VectorPath

if ($testingDoc -notmatch 'twin = cardinality') { throw 'Testing documentation does not define twin cardinality.' }
if ($testingDoc -notmatch 'joker = policy') { throw 'Testing documentation does not define joker policy.' }
if ($testingDoc -notmatch 'authorization subject') { throw 'Publisher-principal neutrality rule missing.' }
if ($vectors -notmatch 'CASE J01') { throw 'Joker separation vector missing.' }
if ($vectors -notmatch 'CASE P02') { throw 'Credential-compromise vector missing.' }

$blocked = $false
try { & $resolver 'oswap upload joker=threshold' | Out-Null } catch { $blocked = $true }
if (-not $blocked) { throw 'Current twin resolver incorrectly accepted joker policy syntax.' }

$blocked = $false
try { & $resolver 'oswap upload twin=2;Remove-Item C:\*' | Out-Null } catch { $blocked = $true }
if (-not $blocked) { throw 'Restricted arithmetic grammar accepted shell injection syntax.' }

Write-Output 'OSWAPSACW twin/joker separation and publisher-principal tests passed.'
