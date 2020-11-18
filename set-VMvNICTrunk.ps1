<#
.SYNOPSIS
    Configure trunk on VM
.DESCRIPTION
    Query user on target VM to configure Trunk
.EXAMPLE
    PS C:\> .\set-VMvNICTrunk.ps1 -RequestedVM tkwlc1 -TargetVID "1061,2001" -VMHost tkhv11 -Verbose -WhatIf
.PARAMETER RequestedVM
    Target VM logical name

.PARAMETER TargetVID
    Trunked Vlans, untagged vlan 0 should not be added

.PARAMETER VMHost
    Hyper-V hosting VM

.NOTES
    2020-11-18 Version 1 /Klas.Pihl@Atea.se
#>
[CmdletBinding(SupportsShouldProcess)]
Param(
   [Parameter(Mandatory=$true,HelpMessage="VM to configure VMnetwork TRUNK")]
   [string]$RequestedVM,

   [Parameter(Mandatory=$true,HelpMessage="Vlan ID to add to trunk, 0 is unatagged. Example: '10,200'")]
   [string]$TargetVID,

   [Parameter(Mandatory=$false,HelpMessage="Hyper-V hosting VM")]
   [string]$VMHost

)
$ErrorActionPreference = 'Stop'
Try {
    if(-not [string]::IsNullOrEmpty($VMHost)) {
        Write-Verbose "Hyper-V host defined, use remote session"
        $HostSession = New-PSSession -ComputerName $VMHost -Credential $null
        $SessionSplatt = @{
            Session = $HostSession
        }
    } else {
        Write-Verbose "Running on current session"
        $SessionSplatt = @{}
    }

    Write-Verbose "Get target VM"
    $TargetVM = Invoke-Command {Get-VM} @SessionSplatt | Where-Object Name -eq $RequestedVM
    if(-not $TargetVM -or $TargetVM.Name.count -ne 1) {
        Write-Verbose "$TargetVM not found"
        Write-Verbose "Count: $($TargetVM.Name.count)"
        Write-Error "VM $RequestedVM not found or scope to wide"
        exit 1
    }
    $VMNetAdapter = Invoke-Command {Get-VMNetworkAdapter -VMName * } @SessionSplatt | Where-Object VMName -eq $TargetVM.Name
    if($VMNetAdapter.count -gt 1) {
        $VMNetAdapter = $VMNetAdapter | Out-GridView -PassThru -Title "Select target vNIC"
    }
    Write-Verbose "Defining VID $TargetVID on $($VMNetAdapter.name)"

    $VlanResult = if($HostSession) {
        Invoke-Command {Set-VMNetworkAdaptervlan -VMName $Using:TargetVM.Name -VMNetworkAdapterName $Using:VMNetAdapter.Name -Trunk -AllowedVlanIdList $Using:TargetVID -NativeVlanId 0 -Passthru } @SessionSplatt
    } else {
        Set-VMNetworkAdaptervlan -VMName $TargetVM.Name -VMNetworkAdapterName $VMNetAdapter.Name -Trunk -AllowedVlanIdList $TargetVID -NativeVlanId 0 -Passthru
    }
    Write-Output $VlanResult | Select-Object OperationMode,PrimaryVlanId,AllowedVlanIdList,ParentAdapter
} Catch {
    write-error $error[0].Exception
    write-error $error[0].InvocationInfo.PositionMessage
    $Error.remove($Error[0])
}
