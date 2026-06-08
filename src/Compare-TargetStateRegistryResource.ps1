<#
Design:
- Phase 6 fresh TargetState comparison helper; not recovered source.
- Compares normalized desired Registry state to observed state and proposes read-only actions.
- Produces difference objects consumed by Test and Plan evidence.
#>
function Compare-TargetStateRegistryResource {
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

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNull()]
        [System.Object]
        $ObservedState
    )

    process {
        $Differences = New-Object System.Collections.ArrayList
        $Action = 'no-op'

        if ($Resource.Ensure -eq 'Absent') {
            if ($ObservedState.ValueExists -eq $true) {
                $Action = 'delete'
                [void]$Differences.Add([pscustomobject][ordered]@{
                    Property = 'Ensure'
                    Desired = 'Absent'
                    Actual = 'Present'
                    Action = $Action
                })
            }
        }
        else {
            if (($ObservedState.KeyExists -ne $true) -or ($ObservedState.ValueExists -ne $true)) {
                $Action = 'create'
                [void]$Differences.Add([pscustomobject][ordered]@{
                    Property = 'Ensure'
                    Desired = 'Present'
                    Actual = 'Absent'
                    Action = $Action
                })
            }
            else {
                if ([System.String]$Resource.ValueKind -ne [System.String]$ObservedState.ValueKind) {
                    $Action = 'update'
                    [void]$Differences.Add([pscustomobject][ordered]@{
                        Property = 'ValueKind'
                        Desired = [System.String]$Resource.ValueKind
                        Actual = [System.String]$ObservedState.ValueKind
                        Action = $Action
                    })
                }

                if ([System.String]$Resource.ValueDataDisplay -ne [System.String]$ObservedState.ValueDataDisplay) {
                    $Action = 'update'
                    [void]$Differences.Add([pscustomobject][ordered]@{
                        Property = 'ValueData'
                        Desired = [System.String]$Resource.ValueDataDisplay
                        Actual = [System.String]$ObservedState.ValueDataDisplay
                        Action = $Action
                    })
                }
            }
        }

        $InDesiredState = [System.Boolean]($Differences.Count -eq 0)
        [pscustomobject][ordered]@{
            InDesiredState = $InDesiredState
            Action = $Action
            Status = if ($InDesiredState) { 'Compliant' } else { 'NonCompliant' }
            Differences = [System.Object[]]$Differences.ToArray()
        }
    }
}
