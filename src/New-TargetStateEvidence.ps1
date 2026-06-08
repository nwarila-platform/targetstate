<#
Design:
- Phase 6 fresh TargetState evidence builder; not recovered source.
- Builds the ADR 0005 read-only result shape for Get, Test, and Plan operations.
- Mutation fields are always false in this phase.
#>
function New-TargetStateEvidence {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Default',
        PositionalBinding = $true
    )]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Operation,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [System.Object]
        $Resource,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateSet('Observed', 'Compliant', 'NonCompliant', 'PlannedChange', 'Changed', 'NoChange', 'Skipped', 'Error')]
        [System.String]
        $Status,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Object]
        $DesiredInput,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Object]
        $ObservedState,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Object[]]
        $Differences,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Nullable[System.Boolean]]
        $InDesiredState,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String]
        $PlannedAction,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String[]]
        $Messages,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.Object[]]
        $Errors,

        [Parameter(Mandatory = $false)]
        [AllowNull()]
        [System.String]
        $DocumentName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RunId = ([System.Guid]::NewGuid().Guid)
    )

    process {
        [pscustomobject][ordered]@{
            RunId = $RunId
            TimestampUtc = [System.DateTime]::UtcNow.ToString('o')
            DocumentName = $DocumentName
            Operation = $Operation
            Resource = [pscustomobject][ordered]@{
                Type = $Resource.ResourceType
                Name = $Resource.Name
                Key = $Resource.RegistryPath
                ValueName = $Resource.ValueName
            }
            DesiredInput = $DesiredInput
            ObservedState = $ObservedState
            Differences = [System.Object[]]@($Differences)
            Status = $Status
            InDesiredState = $InDesiredState
            PlannedAction = $PlannedAction
            Mutation = [pscustomobject][ordered]@{
                Attempted = $false
                Changed = $false
            }
            Messages = [System.String[]]@($Messages)
            Errors = [System.Object[]]@($Errors)
        }
    }
}
