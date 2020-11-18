# Mixed scripts for Hyper-V

## set-VMvNICTrunk
Script made for customer to define a Trunk on vNIC

```powershell

NAME
    D:\OneDrive\OneDrive - Atea\Powershell\GitHub\Hyper-V\set-VMvNICTrunk.ps1

SYNOPSIS
    Configure trunk on VM


SYNTAX
    .\set-VMvNICTrunk.ps1 [-RequestedVM] <String> [-TargetVID] <String> [[-VMHost] <String>] [-WhatIf] [-Confirm]
    [<CommonParameters>]


DESCRIPTION
    Query user on target VM to configure Trunk


PARAMETERS
    -RequestedVM <String>
        Target VM logical name

    -TargetVID <String>
        Trunked Vlans, untagged vlan 0 should not be added

    -VMHost <String>
        Hyper-V hosting VM

    -WhatIf [<SwitchParameter>]

    -Confirm [<SwitchParameter>]

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

    -------------------------- EXAMPLE 1 --------------------------

    PS C:\>.\set-VMvNICTrunk.ps1 -RequestedVM wlc1 -TargetVID "1062,2002" -VMHost hv11 -Verbose -WhatIf
```