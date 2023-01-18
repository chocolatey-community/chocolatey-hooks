function Get-ChocolateyPackageToolsFolder {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [String]
        $PackageName
    )

    process {
        $packageFolder = Get-ChocolateyPath -PathType 'package'
        $toolsDir = Join-Path $packageFolder -ChildPath 'tools'
        return $toolsDir
    }
}