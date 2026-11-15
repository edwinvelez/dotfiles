@echo off
rem dockur copies this folder to C:\OEM and runs this file once, at first logon after install.
rem On an existing VM, run it by hand; setup.ps1 elevates itself.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
