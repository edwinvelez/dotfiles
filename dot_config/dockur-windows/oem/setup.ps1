# Guest tweaks for the dockur Windows 11 VM: Eastern time with automatic resync,
# solid black desktop, and no OneDrive/backup nags. Safe to re-run.

$principal = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$dir = "$env:ProgramData\DockurTweaks"
New-Item -ItemType Directory -Force -Path $dir | Out-Null

# New-Item -Force on an existing registry key wipes its values, so only create missing keys
function Set-Reg($Path, $Name, $Value, $Type = 'DWord') {
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}

# --- Time zone and clock sync ---------------------------------------------

tzutil /s "Eastern Standard Time"
# Keep location-based auto time zone from overriding the setting
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\tzautoupdate' Start 4
# dockur starts QEMU with -rtc base=localtime and compose sets TZ, so the RTC holds Eastern local time
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation' RealTimeIsUniversal 0

# Let w32time correct any offset (after host suspend the guest clock can lag by hours)
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config' MaxPosPhaseCorrection 0xFFFFFFFF
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config' MaxNegPhaseCorrection 0xFFFFFFFF
# 0x9 = client mode + SpecialPollInterval, polled every 15 minutes
Set-Reg 'HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient' SpecialPollInterval 900
Set-Service w32time -StartupType Automatic
Start-Service w32time
w32tm /config /manualpeerlist:"time.windows.com,0x9 pool.ntp.org,0x9" /syncfromflags:manual /update | Out-Null

# Force a resync at boot, logon, RDP reconnect and unlock (a reconnect is not a new logon)
$stateClass = Get-CimClass -Namespace ROOT\Microsoft\Windows\TaskScheduler -ClassName MSFT_TaskSessionStateChangeTrigger
$boot = New-ScheduledTaskTrigger -AtStartup
$boot.Delay = 'PT30S' # Give the network a moment
$triggers = @(
    $boot
    New-ScheduledTaskTrigger -AtLogOn
    New-CimInstance -CimClass $stateClass -ClientOnly -Property @{ StateChange = 3 } # Remote connect
    New-CimInstance -CimClass $stateClass -ClientOnly -Property @{ StateChange = 8 } # Unlock
)
Register-ScheduledTask -TaskPath '\DockurTweaks\' -TaskName 'Resync clock' -Force `
    -Action (New-ScheduledTaskAction -Execute 'cmd.exe' -Argument '/c net start w32time & w32tm /resync') `
    -Trigger $triggers `
    -Principal (New-ScheduledTaskPrincipal -UserId 'SYSTEM' -LogonType ServiceAccount -RunLevel Highest) `
    -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -StartWhenAvailable) | Out-Null

# --- Solid black desktop --------------------------------------------------

# Spotlight can replace the wallpaper on its own; these policy keys need admin, so set them here
Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' DisableWindowsSpotlightFeatures 1
Set-Reg 'HKCU:\Software\Policies\Microsoft\Windows\CloudContent' DisableSpotlightCollectionOnDesktop 1

# Unactivated Windows locks the Personalization UI, but the registry and user32 calls still work.
# This script is re-applied at every logon so nothing can quietly restore the default wallpaper.
@'
function Set-Reg($Path, $Name, $Value, $Type = 'DWord') {
    if (-not (Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
}
Set-Reg 'HKCU:\Control Panel\Colors' Background '0 0 0' String
Set-Reg 'HKCU:\Control Panel\Desktop' WallPaper '' String
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers' BackgroundType 1 # Solid color

Add-Type -Namespace Win32 -Name Desktop -MemberDefinition @"
[DllImport("user32.dll", CharSet = CharSet.Unicode)]
public static extern bool SystemParametersInfo(int action, int param, string value, int flags);
[DllImport("user32.dll")]
public static extern bool SetSysColors(int count, int[] elements, int[] colors);
"@
[Win32.Desktop]::SetSysColors(1, @(1), @(0)) | Out-Null                # COLOR_DESKTOP = black
[Win32.Desktop]::SystemParametersInfo(0x14, 0, '', 3) | Out-Null       # SPI_SETDESKWALLPAPER, persist + broadcast
'@ | Set-Content -Encoding UTF8 "$dir\desktop.ps1"

Register-ScheduledTask -TaskPath '\DockurTweaks\' -TaskName 'Black desktop' -Force `
    -Action (New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$dir\desktop.ps1`"") `
    -Trigger (New-ScheduledTaskTrigger -AtLogOn) `
    -Principal (New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Users' -RunLevel Limited) `
    -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries) | Out-Null

& "$dir\desktop.ps1"

# --- OneDrive and backup nags ---------------------------------------------

# "Let's finish setting up your device" (offers OneDrive and Windows Backup)
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement' ScoobeSystemSettingEnabled 0
# Welcome experience and tips/suggestion toasts
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-310093Enabled' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' 'SubscribedContent-338389Enabled' 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings\Windows.SystemToast.Suggested' Enabled 0
# "Back up your files" badges in the Start menu account flyout and on Settings home
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' Start_AccountNotifications 0
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications' EnableAccountNotifications 0
# OneDrive ads in File Explorer
Set-Reg 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' ShowSyncProviderNotifications 0

# Block OneDrive by policy, including its "back up your folders" prompt, then remove it
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' DisableFileSyncNGSC 1
Set-Reg 'HKLM:\SOFTWARE\Policies\Microsoft\OneDrive' KFMBlockOptIn 1
Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue
$setups = @(
    "$env:SystemRoot\System32\OneDriveSetup.exe"
    "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\OneDrive\*\OneDriveSetup.exe" -ErrorAction SilentlyContinue
) | Where-Object { $_ -and (Test-Path $_) }
foreach ($setup in $setups) { Start-Process $setup '/uninstall' -Wait }
Remove-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' OneDrive -ErrorAction SilentlyContinue

Write-Host 'Done. Sign out or restart Windows for Explorer and Start menu changes to apply.'
