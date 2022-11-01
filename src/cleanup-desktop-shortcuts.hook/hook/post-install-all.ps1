if (-not $packageScript) {
    #Warning was provided in pre-install script
    return
}

if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("DesktopDirectory"))) {
    Write-Warning "Skipping cleanup because user desktop directory cannot be found"
    return
}

$global:CleanupDesktopShortcutsHook.PostShortcuts = @(Get-Childitem -Path ([environment]::GetFolderPath("DesktopDirectory")) -Filter "*.lnk")

if (Test-ProcessAdminRights) {
    if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("CommonDesktopDirectory"))) {
        Write-Warning "System wide desktop directory cannot be found, something went wrong."
        Write-Warning "Skipping cleanup of desktop shortcuts"
        return
    }
    $global:CleanupDesktopShortcutsHook.PostShortcuts += @(Get-Childitem -Path ([environment]::GetFolderPath("CommonDesktopDirectory")) -Filter "*.lnk")
} else {
    Write-Host "Not cleaning desktop shortcuts from the system wide desktop directory as script is not running with Admin rights."
}

foreach ($postshortcut in $CleanupDesktopShortcutsHook.PostShortcuts) {
    if ($CleanupDesktopShortcutsHook.PreShortcuts) {
        if ($CleanupDesktopShortcutsHook.PreShortcuts.fullname.Contains($postshortcut.fullname)) {
            Write-Debug "'$($postshortcut.fullname)' existed before install script run, ignoring"
            continue;
        }
    }
    Write-Host "Removing '$($postshortcut.fullname)'"
    Remove-Item -Path $postshortcut.fullname
}
