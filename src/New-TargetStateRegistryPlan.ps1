<#
Design:
- Phase 6 fresh TargetState Registry plan operation; not recovered source.
- Produces create/update/delete/no-op evidence without changing live state.
- Registry access is mocked in tests.
#>
function New-TargetStateRegistryPlan {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Default',
        PositionalBinding = $true
    )]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [System.Object]
        $Resource,

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
        $GetEvidence = Get-TargetStateRegistryResource -Resource $Resource -DocumentName $DocumentName -RunId $RunId
        $Comparison = Compare-TargetStateRegistryResource -Resource $Resource -ObservedState $GetEvidence.ObservedState
        $Status = if ($Comparison.Action -eq 'no-op') { 'NoChange' } else { 'PlannedChange' }

        New-TargetStateEvidence -Operation 'Plan' -Resource $Resource -Status $Status -DesiredInput $Resource -ObservedState $GetEvidence.ObservedState -Differences $Comparison.Differences -InDesiredState $Comparison.InDesiredState -PlannedAction $Comparison.Action -Messages $GetEvidence.Messages -Errors $GetEvidence.Errors -DocumentName $DocumentName -RunId $RunId
    }
}
