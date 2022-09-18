if (-not $packageScript) {
    #Warning was provided in pre-install script
    return
}

if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("DesktopDirectory"))) {
    Write-Warning "Skipping cleanup because user desktop directory cannot be found"
    return
}

[array]$global:cleanup_desktop_shortcuts_hook_post_shortcuts = Get-Childitem -Path ([environment]::GetFolderPath("DesktopDirectory")) -Filter "*.lnk"

if (Test-ProcessAdminRights) {
    if ([string]::IsNullOrEmpty([Environment]::GetFolderPath("CommonDesktopDirectory"))) {
        Write-Warning "System wide desktop directory cannot be found, something went wrong."
        Write-Warning "Skipping cleanup of desktop shortcuts"
        return
    }
    $global:cleanup_desktop_shortcuts_hook_post_shortcuts += Get-Childitem -Path ([environment]::GetFolderPath("CommonDesktopDirectory")) -Filter "*.lnk"
} else {
    Write-Host "Not cleaning desktop shortcuts from the system wide desktop directory as script is not running with Admin rights."
}

foreach ($postshortcut in $cleanup_desktop_shortcuts_hook_post_shortcuts) {
    if (($null -ne $cleanup_desktop_shortcuts_hook_pre_shortcuts)) {
        if ($cleanup_desktop_shortcuts_hook_pre_shortcuts.name.Contains($postshortcut.name)) {
            Write-Debug "'$($postshortcut.name)' existed before install script run, ignoring"
            continue;
        }
    }
    Write-Host "Removing '$($postshortcut.name)'"
    Remove-Item -Path $postshortcut.fullname
}
