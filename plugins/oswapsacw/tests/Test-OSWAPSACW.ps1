# SPDX-License-Identifier: Apache-2.0
#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$PluginRoot = Split-Path -Parent $PSScriptRoot
$ManifestPath = Join-Path $PluginRoot '.codex-plugin\plugin.json'
$AppsPath = Join-Path $PluginRoot '.app.json'
$McpPath = Join-Path $PluginRoot '.mcp.json'
$SkillPath = Join-Path $PluginRoot 'skills\oswapsacw\SKILL.md'
$SchemaPath = Join-Path $PluginRoot 'schemas\audit-record.schema.json'

$manifest = Get-Content -Raw $ManifestPath | ConvertFrom-Json
$apps = Get-Content -Raw $AppsPath | ConvertFrom-Json
$mcp = Get-Content -Raw $McpPath | ConvertFrom-Json
$schema = Get-Content -Raw $SchemaPath | ConvertFrom-Json
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
if ($schema.title -ne 'OSWAPSACW Audit Record') { throw 'Audit schema title mismatch.' }

$defaults = @($manifest.interface.defaultPrompt)
if ($defaults.Count -gt 3) { throw 'Plugin has more than three default prompts.' }
foreach ($prompt in $defaults) {
    if ($prompt.Length -gt 128) { throw "Default prompt exceeds 128 characters: $prompt" }
}

Write-Output 'OSWAPSACW plugin conformance checks passed.'
Write-Output 'Canonical: oswap upload twin=N'
Write-Output 'Canonical: oswap download twin=N'

$resolver = Join-Path $PluginRoot 'scripts\Resolve-OSWAPSACWCommand.ps1'
$upload = (& $resolver 'oswap upload twin=(9/3)' | ConvertFrom-Json)
$download = (& $resolver 'oswap download twin=2' | ConvertFrom-Json)
if ($upload.verb -ne 'upload' -or -not $upload.requires_remote_write_authorization) { throw 'Upload intent resolution failed.' }
if ($download.verb -ne 'download' -or -not $download.may_modify_local_state) { throw 'Download intent resolution failed.' }
Write-Output 'OSWAPSACW command intent resolution passed.'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PluginRoot)
$MarketplacePath = Join-Path $RepoRoot '.agents\plugins\marketplace.json'
$marketplace = Get-Content -Raw $MarketplacePath | ConvertFrom-Json
$entry = @($marketplace.plugins | Where-Object { $_.name -eq 'oswapsacw' })
if ($entry.Count -ne 1 -or $entry[0].source.path -ne './plugins/oswapsacw') { throw 'Marketplace OSWAPSACW entry is invalid.' }
Write-Output 'Marketplace entry validation passed.'
