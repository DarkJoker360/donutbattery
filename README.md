# Donutbattery Windows

Donutbattery is a cli tool written in powershell showing battery informations of computer and connected android devices, using ADB and Root..

Tested on Windows 8.1, 10, 11.

Currently supported Android OEMs are: Xiaomi, OnePlus, Samsung.

Pull requests and contributions are welcome.

<img src="https://i.imgur.com/wI0WPqK.jpg" >

## How to install / run
Put `donutbattery.ps1` in a powershell executable path and run with `donutbattery` command

Alternatively the tool can be executed onetime only with `.\donutbattery.ps1` command

Script arguments:  
- `-v | --version : Shows donutbattery version`  
- `-w | --windows-report : Generates and shows windows battery report` (a web browser must be installed)  
- `-h | --help : Shows the two previous usage lines`

## Knows issues / TODO
* Computers with more than one battery may give some issues

## Additional Notes
In order to have device section working you have to put adb.exe and its dependencies in a
powershell executable path. (For reference: https://wiki.lineageos.org/adb_fastboot_guide#on-windows)
