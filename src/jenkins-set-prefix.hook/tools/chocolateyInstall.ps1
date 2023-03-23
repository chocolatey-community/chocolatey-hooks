$ErrorActionPreference = "Stop"

# If we are running on a system that doesn't have $PSScriptRoot, define it
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
}

# If a parameter is provided, set a file to ensure we don't lose the prefix we intend to use
$Params = Get-PackageParameters
$VariableFile = Join-Path $PSScriptRoot "..\hook\prefixvalue.txt"

$Prefix = if ($Params.ContainsKey("Prefix")) {
    $Params["Prefix"]
} elseif (Test-Path $VariableFile) {
    Get-Content $VariableFile
} else {
    "jenkins"
}

Set-Content -Path $VariableFile -Value $Prefix.TrimStart("/")