$ErrorActionPreference = "Stop"

# Though recent Jenkins doesn't support any such systems...
# If we are running on a system that doesn't have $PSScriptRoot, define it
if (-not $PSScriptRoot) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Definition -Parent
}

$Prefix = Get-Content -Path $PSScriptRoot\prefixvalue.txt

# Get the path to the XML config file
$RegistryPath = "HKLM:\SOFTWARE\Jenkins\InstalledProducts\Jenkins"
if (Test-Path $RegistryPath) {
    $InstallDirectory = Get-ItemPropertyValue -Path $RegistryPath -Name "InstallLocation"
    $XmlPath = Join-Path $InstallDirectory "Jenkins.xml"
} else {
    throw "Jenkins is not installed correctly."
}

# If it's missing or different, add the prefix to the config arguments
if (Test-Path $XmlPath) {
    [xml]$JenkinsXml = Get-Content $XmlPath

    if ($JenkinsXml.SelectSingleNode("/service/arguments")."#text" -notmatch "--prefix=/$Prefix") {
        $JenkinsXml.SelectSingleNode("/service/arguments")."#text" = $JenkinsXml.SelectSingleNode("/service/arguments")."#text" -replace "\s*--prefix=/.+?\b", ""
        $JenkinsXml.SelectSingleNode("/service/arguments")."#text" += " --prefix=/$Prefix"
        $JenkinsXml.Save($XmlPath)
    }
} else {
    throw "Could not find '$XmlPath'"
}

Restart-Service Jenkins