<#
Design:
- Phase 6 fresh TargetState Registry test operation; not recovered source.
- Calls the read operation and returns compliance evidence without changing live state.
- Registry access is mocked in tests.
#>
function Test-TargetStateRegistryResource {
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

        New-TargetStateEvidence -Operation 'Test' -Resource $Resource -Status $Comparison.Status -DesiredInput $Resource -ObservedState $GetEvidence.ObservedState -Differences $Comparison.Differences -InDesiredState $Comparison.InDesiredState -Messages $GetEvidence.Messages -Errors $GetEvidence.Errors -DocumentName $DocumentName -RunId $RunId
    }
}
