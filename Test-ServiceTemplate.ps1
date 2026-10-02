#Requires -Version 7.4
[CmdletBinding()]
param([string]$TofuPath = 'tofu')

$ErrorActionPreference = 'Stop'
$Root = $PSScriptRoot
$Manifest = Get-Content -LiteralPath (Join-Path $Root '.factory-template.json') -Raw | ConvertFrom-Json -AsHashtable
if ($Manifest.SchemaVersion -ne 1 -or $Manifest.Name -cne 'service-template' -or $Manifest.Version -cnotmatch '^v[0-9]+\.[0-9]+\.[0-9]+$') {
    throw 'Invalid template identity or release version.'
}
if ($Manifest.Source.Repository -cne 'csoc-foundation/csoc-monitor' -or $Manifest.Source.Commit -cnotmatch '^[a-f0-9]{40}$') {
    throw 'The reviewed source repository and commit must be recorded.'
}
if ($Manifest.DeploymentEnabled -ne $false) { throw 'Deployment must remain disabled in the base template.' }
foreach ($RequiredFile in $Manifest.RequiredFiles) {
    if ($RequiredFile -match '(^/|\\|\.\.)' -or -not (Test-Path -LiteralPath (Join-Path $Root $RequiredFile) -PathType Leaf)) {
        throw "Missing or invalid required file: $RequiredFile"
    }
}
$Files = @(Get-ChildItem -LiteralPath $Root -Recurse -File -Force | Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' })
foreach ($SourceFile in $Files) {
    $RelativePath = [IO.Path]::GetRelativePath($Root, $SourceFile.FullName).Replace('\', '/')
    if ($SourceFile.Extension -in @('.pem', '.pfx', '.p12', '.key') -or $SourceFile.Name -like '*.tfstate*') {
        throw "Credential or state file found: $RelativePath"
    }
    if ($SourceFile.Extension -eq '.ps1') {
        $Tokens = $null
        $ParseErrors = $null
        [Management.Automation.Language.Parser]::ParseFile($SourceFile.FullName, [ref]$Tokens, [ref]$ParseErrors) | Out-Null
        if ($ParseErrors.Count) { throw "PowerShell syntax errors in $RelativePath" }
    }
    if ($SourceFile.Extension -eq '.hcl') {
        $Hcl = (Get-Content -LiteralPath $SourceFile.FullName -Raw).TrimEnd([char[]]"`r`n")
        $Hcl | & $TofuPath fmt -check -
        if ($LASTEXITCODE -ne 0) { throw "Invalid or unformatted HCL in $RelativePath" }
    }
    if ($RelativePath.StartsWith('infra/') -or $RelativePath.StartsWith('.github/workflows/')) {
        $Content = Get-Content -LiteralPath $SourceFile.FullName -Raw
        if ($Content -match 'csoc-monitor|BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY') {
            throw "Service-specific or private-key content in $RelativePath"
        }
        if ($RelativePath.StartsWith('.github/workflows/') -and $Content -match 'id-token:\s*write|azure/login@|pull_request_target:') {
            throw "Deployment credentials or privileged triggers are not allowed in $RelativePath"
        }
    }
}
Write-Information "Validated $($Files.Count) template files at $($Manifest.Version). Deployment remains disabled." -InformationAction Continue