#
# SPDX-License-Identifier: GPL-3.0
#

$version="2.2"

$batt_obj = (Get-WmiObject Win32_Battery -ComputerName $env:COMPUTERNAME)

function Usage {
    Write-Output "Usage: donutbattery

    Donutbattery is a cli tool written in bash showing battery informations.

    OPTIONS
        -v | --version : Shows donutbattery version
        -w | --windows-report : Generates and shows windows battery report
                                (a web browser must be installed)"
}

function Detect-Device {
    # TODO: Handle properly device detection.
     if ($(adb devices) -eq 0) {
        if ($(adb root) -eq 0) {
            Exit 1
        } elif ($(adb shell su -c test ls)) {
            Exit 1
        }
     }
     Exit 0
}

function Print-Infos {
    $batt_obj | ForEach-Object {
        $model = $batt_obj.Name
        $manufacturer = $batt_obj.DeviceID
        $level = $batt_obj.EstimatedChargeRemaining
        $designed_capacity = (Get-WmiObject -Class BatteryStaticData -Namespace ROOT\WMI).DesignedCapacity
        $fullcharge_capacity = (Get-WmiObject -Class BatteryFullChargedCapacity -Namespace ROOT\WMI).FullChargedCapacity
        $health = [int] (100*($fullcharge_capacity/$designed_capacity))
        $voltage = $batt_obj.DesignVoltage
        $status_val = $batt_obj.BatteryStatus

        Switch ($status_val) {
            { $_ -lt 1 } { $status = "Unknown" }
            { $_ -eq 1 } { $status = "Discharging" }
            { $_ -eq 2 } { $status = "Charging" }
            { $_ -eq 3 } { $status = "Charging - Fully Charged" }
            { $_ -eq 4 } { $status = "Discharging - Low" }
            { $_ -eq 5 } { $status = "Discharging -  Critical" }
            { $_ -eq 6 } { $status = "Charging" }
            { $_ -eq 7 } { $status = "Charging - High" }
            { $_ -eq 8 } { $status = "Charging - Low" }
            { $_ -eq 9 } { $status = "Charging - Critical" }
            { $_ -gt 9 } { $status = "Unknown" }
        }

        Write-Output "*********** $model ***********"
        Write-Output "Manufacturer: $manufacturer"
        Write-Output "Status: $status"
        Write-Output "Level: $level%"
        Write-Output "Health: $health%"
        Write-Output "Full charge capacity: $fullcharge_capacity Wh"
        Write-Output "Designed Capacity: $designed_capacity Wh"
        Write-Output "Voltage: $(($batt_obj.DesignVoltage) / 1000)V"
        Write-Output "************************************"
    }
}

function Print-Device-Infos {
    $bat_dir = "/sys/class/power_supply/battery"
    $bms_dir = "/sys/class/power_supply/bms"
    $device_name = Write-output $(adb shell getprop ro.product.vendor.model)
    $device_oem = Write-Output $(adb shell getprop ro.product.vendor.manufacturer)
    Switch ($device_oem) {
        { $_ -eq "Xiaomi" } {
            $status = Write-Output $(Read-Device-Sysfs $bat_dir/status)
            $level = Write-Output $(Read-Device-Sysfs $bat_dir/capacity)
            $cycles = Write-Output $(Read-Device-Sysfs $bms_dir/cycle_count)
            $health = Write-Output $(Read-Device-Sysfs $bat_dir/health)
            $tech = Write-Output $(Read-Device-Sysfs $bat_dir/technology)
            $fc_cap = Write-Output $(Read-Device-Sysfs $bat_dir/charge_full)
            $d_cap = Write-Output $(Read-Device-Sysfs $bat_dir/charge_full_design)
            $v = Write-Output $(Read-Device-Sysfs $bat_dir/voltage_now)
            $battery_health =  [int] (100 * ($fc_cap/$d_cap))
        }
        { $_ -eq "OnePlus" } {
            $status = Write-Output $(Read-Device-Sysfs $bat_dir/status)
            $level = Write-Output $(Read-Device-Sysfs $bat_dir/capacity)
            $cycles = Write-Output $(Read-Device-Sysfs $bat_dir/cycle_count)
            $health = Write-Output $(Read-Device-Sysfs $bat_dir/health)
            $tech = Write-Output $(Read-Device-Sysfs $bat_dir/technology)
            $fc_cap = Write-Output $(Read-Device-Sysfs $bat_dir/charge_full)
            $d_cap = Write-Output $(Read-Device-Sysfs $bat_dir/charge_full_design)
            $v = Write-Output $(Read-Device-Sysfs $bat_dir/voltage_now)
            $battery_health =  [int] (100000 * ($fc_cap/$d_cap))
        }
        { $_ -eq "samsung" } {
            $status = Write-Output $(Read-Device-Sysfs $bat_dir/status)
            $level = Write-Output $(Read-Device-Sysfs $bat_dir/capacity)
            $cycles = ""
            $health = Write-Output $(Read-Device-Sysfs $bat_dir/health)
            $tech = Write-Output $(Read-Device-Sysfs $bat_dir/technology)
            $fc_cap = Write-Output $(Read-Device-Sysfs $bat_dir/charge_full)
            $d_cap = Write-Output $(Read-Device-Sysfs $bat_dir/charge_full_design)
            $v = Write-Output $(Read-Device-Sysfs $bat_dir/voltage_now)
            $battery_health =  [int] (100000 * ($fc_cap/$d_cap))
        }
        Default {
            $status = Write-Output $(Read-Device-Sysfs $bat_dir/status)
            $level = Write-Output $(Read-Device-Sysfs $bat_dir/capacity)
        }
    }

    Write-Output "*********** $device_name ***********"
    Write-Output "Manufacturer: $device_oem"
    if ($status -ne "") { Write-Output "Status: $status" }
    if ($level -ne "") { Write-Output "Level: $level%" }
    if ($battery_health -ne "") { Write-Output "Health: $battery_health%" }
    if ($fc_cap -ne "") { Write-Output "Full charge capacity: $fc_cap µWh" }
    if ($d_cap -ne "") { Write-Output "Designed Capacity: $d_cap µWh" }
    if ($v -ne "") { Write-Output "Voltage: $v µV" }
    Write-Output "************************************"
}

function Read-Device-Sysfs { Param ( [string] $Path )
    if($(adb shell cat $Path)){
         $(adb shell cat $Path)
    } else {
        $(adb shell su -c cat $Path)
    }
}

Switch($args[0]) {
    { $_ -eq "-v" -or $_ -eq "--version" } { Write-Output "Donutbattery $version"}
    { $_ -eq "-w" -or $_ -eq "--generate-windows-report" } {
        powercfg /BATTERYREPORT /output win_report.html
        Invoke-Expression ".\win_report.html"
    }
    { $_ -eq "-h" -or $_ -eq "--help" } { Usage }
    Default {
        Print-Infos
        Detect-Device 2>&1 | Out-Null
        Print-Device-Infos
    }
}
