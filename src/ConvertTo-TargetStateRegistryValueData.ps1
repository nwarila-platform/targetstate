<#
Design:
- Phase 6 fresh TargetState helper; not recovered source and not an alias for an absent recovered name.
- Produces comparable and evidence-friendly Registry value data without changing live state.
- Reuses recovered value-kind and array/byte formatting helpers.
#>
function ConvertTo-TargetStateRegistryValueData {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Default',
        PositionalBinding = $true
    )]
    param(
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Default',
            Position = 0
        )]
        [AllowNull()]
        [System.Object]
        $ValueData,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 1
        )]
        [ValidateNotNull()]
        [System.Object]
        $ValueKind
    )

    process {
        $Kind = Get-RegistryValueKindStr -ValueKind ([System.String]$ValueKind)
        $KindName = [System.String]$Kind
        $ComparableValue = $null
        $DisplayValue = $null

        switch ($KindName) {
            'Binary' {
                if ($null -eq $ValueData) {
                    $ComparableValue = $null
                    $DisplayValue = $null
                }
                elseif ($ValueData -is [System.Array] -and -not ($ValueData -is [System.String])) {
                    $ByteValues = @($ValueData | ForEach-Object { [System.Byte]$PSItem })
                    $ComparableValue = [System.String](Convert-ByteArrayToHexString -ByteArray ([System.Byte[]]$ByteValues)).ToLowerInvariant()
                    $DisplayValue = $ComparableValue
                }
                else {
                    $ComparableValue = ([System.String]$ValueData -replace '[^0-9A-Fa-f]', '').ToLowerInvariant()
                    $DisplayValue = $ComparableValue
                }
            }
            'DWord' {
                $ComparableValue = [System.Int64]$ValueData
                $DisplayValue = [System.String]$ComparableValue
            }
            'QWord' {
                $ComparableValue = [System.Int64]$ValueData
                $DisplayValue = [System.String]$ComparableValue
            }
            'MultiString' {
                $ComparableValue = [System.String[]]@($ValueData | ForEach-Object { [System.String]$PSItem })
                $DisplayValue = ConvertFrom-Array -Value $ComparableValue
            }
            'String' {
                $ComparableValue = [System.String]$ValueData
                $DisplayValue = $ComparableValue
            }
            'ExpandString' {
                $ComparableValue = [System.String]$ValueData
                $DisplayValue = $ComparableValue
            }
            'None' {
                $ComparableValue = $ValueData
                if ($null -ne $ValueData) {
                    $DisplayValue = [System.String]$ValueData
                }
            }
            default {
                $ComparableValue = $ValueData
                if ($null -ne $ValueData) {
                    $DisplayValue = [System.String]$ValueData
                }
            }
        }

        [pscustomobject][ordered]@{
            Kind = $KindName
            Value = $ComparableValue
            DisplayValue = $DisplayValue
        }
    }
}
