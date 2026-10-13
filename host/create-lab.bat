@echo off
REM Creates the NAT Network and both virtual machines in VirtualBox.
REM Run it on YOUR computer (Windows), not inside a VM.
REM
REM   host\create-lab.bat  <ubuntu-server.iso>  <ubuntu-desktop.iso>
REM
REM Example:
REM   host\create-lab.bat C:\Users\me\Downloads\ubuntu-24.04.3-live-server-amd64.iso C:\Users\me\Downloads\ubuntu-24.04.3-desktop-amd64.iso

if "%~2"=="" (
  echo Usage: host\create-lab.bat ^<ubuntu-server.iso^> ^<ubuntu-desktop.iso^>
  exit /b 1
)

set VBOX="C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

REM 1. The NAT Network: 222.22.22.0/24 with DHCP
%VBOX% natnetwork add --netname group22_nat --network "222.22.22.0/24" --dhcp on
%VBOX% natnetwork start --netname group22_nat

REM 2. Build both VMs: 4096 MB RAM, 2 CPUs, 25 GB disk, on group22_nat
call :make_vm UbuntuServer "%~1"
call :make_vm UbuntuDesktop "%~2"

REM 3. Start both so you can install Ubuntu
%VBOX% startvm UbuntuServer
%VBOX% startvm UbuntuDesktop

echo.
echo Done. Install Ubuntu in both windows:
echo   UbuntuServer  -^> server name: group22-02, username: group22
echo   UbuntuDesktop -^> computer name: group22-01, username: group22
exit /b 0

:make_vm
set NAME=%~1
set ISO=%~2
set DISK=%USERPROFILE%\VirtualBox VMs\%NAME%\%NAME%.vdi
%VBOX% createvm --name %NAME% --ostype Ubuntu_64 --register
%VBOX% modifyvm %NAME% --memory 4096 --cpus 2 --vram 16 --graphicscontroller vmsvga --nic1 natnetwork --nat-network1 group22_nat
%VBOX% createmedium disk --filename "%DISK%" --size 25600
%VBOX% storagectl %NAME% --name SATA --add sata --controller IntelAhci
%VBOX% storageattach %NAME% --storagectl SATA --port 0 --device 0 --type hdd --medium "%DISK%"
%VBOX% storageattach %NAME% --storagectl SATA --port 1 --device 0 --type dvddrive --medium "%ISO%"
exit /b 0
