if (-not $packageScript) {
    Write-Host "Skipping Cleanup of Desktop Shortcuts as there is no install script for this package"
    return
}

if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("DesktopDirectory"))) {
    Write-Warning "User desktop directory cannot be found, is Chocolatey running as SYSTEM?"
    return
}

$global:CleanupDesktopShortcutsHook = @{
    PreShortcuts = @(Get-Childitem -Path ([environment]::GetFolderPath("DesktopDirectory")) -Filter "*.lnk")
}

if (Test-ProcessAdminRights) {
    if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("CommonDesktopDirectory"))) {
        Write-Warning "System wide desktop directory cannot be found, something went wrong."
        return
    }
    $global:CleanupDesktopShortcutsHook.PreShortcuts += @(Get-Childitem -Path ([environment]::GetFolderPath("CommonDesktopDirectory")) -Filter "*.lnk")
}
