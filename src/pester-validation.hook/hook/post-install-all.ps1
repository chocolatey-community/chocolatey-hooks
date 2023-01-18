$ErrorActionPreference = 'Stop'
$toolsDir = Split-Path $MyInvocation.MyCommand.Definition
$pp = Get-PackageParameters
$helpers = Join-Path $toolsDir -ChildPath 'helpers.ps1'
. $helpers

$toolsDir = Get-ChocolateyPackageToolsFolder -PackageName $env:ChocolateyPackagename

if (Test-Path (Join-Path $toolsDir -ChildPath 'tests')) {
  $testDir = Join-Path $toolsDIr -ChildPath 'tests'
}

if ($testDir) {
  if (-not $pp['SkipPackageValidation']) {
    $files = (Get-ChildItem $testDir -Recurse -Filter *.ps1).FullName
  
    $containers = $files | Foreach-Object {
      New-PesterContainer -Path $_
    }

    $configuration = [PesterConfiguration]@{
      Run    = @{
        Container = $containers
        Passthru  = $true
      }
      Output = @{
        Verbosity = 'Detailed'
      }
    }

    $results = Invoke-Pester -Configuration $configuration

    if ($results.FailedCount -gt 0) {
      $results
      throw "Package validation failed. Please check results"
    }
    else { 
      $results 
    }
  }
  else {
    Write-Host "Package validation has been skipped via package parameter: SkipPackageValidation"
  }
}
else {
  Write-Host "No tests exist for $($env:ChocolateyPackageName), not validating installation"
}
