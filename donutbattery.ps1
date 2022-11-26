#
# SPDX-License-Identifier: GPL-3.0
#

$version="2.0"

$batt_obj = (Get-WmiObject Win32_Battery -ComputerName $env:COMPUTERNAME)

function Usage {
    Write-Output "Usage: donutbattery
    
    Donutbattery is a cli tool written in bash showing battery informations.
    
    OPTIONS
        -v | --version : Shows donutbattery version"
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
            { $_ -eq 2 } { $status = "Unknown" }
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

Switch($args[0]) {
    { $_ -eq "-v" -or $_ -eq "--version" } { Write-Output "Donutbattery $version"}
    { $_ -eq "-h" -or $_ -eq "--help" } { Usage }
    Default { Print-Infos }
}