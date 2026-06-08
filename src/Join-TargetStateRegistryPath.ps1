<#
Design:
- Phase 6 fresh TargetState helper; not recovered source and not an alias for an absent recovered name.
- Builds a Registry provider path for read-only operations from a validated hive and document path.
- Uses the recovered hive normalizer as an input to the Phase 6 contract.
#>
function Join-TargetStateRegistryPath {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Default',
        PositionalBinding = $true
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Hive,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 1
        )]
        [AllowEmptyString()]
        [ValidateNotNull()]
        [System.String]
        $Path
    )

    process {
        $NormalizedHive = Get-RegistryKeyHive -RegistryKey $Hive
        $Separator = [System.Char]92
        $PathText = ([System.String]$Path).Replace([System.Char]47, $Separator).Trim($Separator)

        if ([System.String]::IsNullOrWhiteSpace($PathText)) {
            return [System.String]('Registry::{0}' -f $NormalizedHive)
        }

        [System.String]('Registry::{0}{1}{2}' -f $NormalizedHive, $Separator, $PathText)
    }
}
