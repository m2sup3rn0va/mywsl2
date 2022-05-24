#Requires -RunAsAdministrator

param
(
    $action
);

Add-Type -AssemblyName System.Windows.Forms
$dateTime = Get-Date -UFormat "%d%B%Y"

switch -Exact ($action)
{
    "backup"
    {
        Write-Host "Preparing Backup..."
        $distroName = Read-Host -Prompt "Distro Name"
        
        $backupPathHandle = New-Object System.Windows.Forms.FolderBrowserDialog
        $backupPathHandle.Description = "Choose a folder where you want to save the WSL2 Distro Backup"
        Write-Host "Choose Path to save Backup from the Dialog box"
        $null = $backupPathHandle.ShowDialog()
        $backupPath = $backupPathHandle.SelectedPath
        $backupPath = $backupPath + "\" + $distroName + "-" + $dateTime + ".tar"

        Write-Host "Initiating Backup"
        Write-Host "Please be patient. It will take a while...."
        C:\Windows\system32\wsl.exe --shutdown
        C:\Windows\system32\wsl.exe --export $distroName $backupPath

        Write-Host "Backup Successfully Completed"
        Write-Host
    }

    "restore"
    {
        Write-Host "Preparing Backup Restore..."
        $distroNewName = Read-Host -Prompt "New name for the Distro"

        $restorePathHandle = New-Object System.Windows.Forms.FolderBrowserDialog
        $restorePathHandle.Description = "Choose a folder where you want to restore the WSL2 Distro Backup"
        Write-Host "Choose Path to restore Backup from the Dialog box"
        $null = $restorePathHandle.ShowDialog()
        $restorePath = $restorePathHandle.SelectedPath + "\"

        $backupPathHandle = New-Object System.Windows.Forms.OpenFileDialog
        $backupPathHandle.InitialDirectory = $PWD.Path
        $backupPathHandle.Filter = 'Archive|*.tar'
        Write-Host "Select the WSL2 Distro Backup from the Dialog box"
        $null = $backupPathHandle.ShowDialog()
        $backupPath = $backupPathHandle.FileName

        Write-Host "Initiating Backup Restore"
        Write-Host "Please be patient. It will take a while...."
        C:\Windows\system32\wsl.exe --import $distroNewName $restorePath $backupPath

        if (!(Test-Path -Path $profile))
        {
            New-item –type file –force $profile
        }

        Add-Content -Path $profile -Value "`nFunction kali"
        Add-Content -Path $profile -Value "{"
        Add-Content -Path $profile -Value "`tC:\Windows\system32\wsl.exe -d MyKali --user user --cd ~ --exec neofetch"
        Add-Content -Path $profile -Value "}"

        C:\Windows\system32\wsl.exe --list --all
        Write-Host "Backup Restoration Successfully Completed"
        Write-Host
    }

    "cleanup"
    {
        Write-Host "Initiating Distro Cleanup..."
        $distroName = Read-Host -Prompt "Distro Name"

	    C:\Windows\system32\wsl.exe --shutdown
	    C:\Windows\system32\wsl.exe --terminate $distroName
	    C:\Windows\system32\wsl.exe --unregister $distroName
        
        Write-Host "Distro has been cleaned. Uninstall the distro by searching in Start Menu"
        Write-Host
    }

    default
    {
        Write-Host "[+] HELP MENU [+]`n`n.\WSL2DR.ps1 -action {backup | restore | cleanup}"
        Write-Host
    }
}