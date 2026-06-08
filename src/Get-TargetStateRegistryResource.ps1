<#
Design:
- Phase 6 fresh TargetState Registry read operation; not recovered source.
- Reads current key/value state for a normalized resource and returns ADR 0005 evidence.
- Runtime registry reads are isolated behind cmdlets that are mocked in tests.
#>
function Get-TargetStateRegistryResource {
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
        $Messages = New-Object System.Collections.ArrayList
        $Errors = New-Object System.Collections.ArrayList
        $KeyExists = $false
        $ValueExists = $false
        $ObservedKind = $null
        $ObservedData = $null
        $ObservedDisplay = $null

        try {
            $KeyExists = [System.Boolean](Test-Path -LiteralPath $Resource.RegistryPath)
        }
        catch {
            [void]$Errors.Add($PSItem)
        }

        if ($KeyExists -eq $true) {
            $RegistryKey = $null
            try {
                $RegistryKey = Get-Item -LiteralPath $Resource.RegistryPath -ErrorAction Stop
            }
            catch {
                [void]$Errors.Add($PSItem)
            }

            try {
                if ([System.String]::IsNullOrEmpty($Resource.ValueName)) {
                    $ItemProperties = Get-ItemProperty -LiteralPath $Resource.RegistryPath -ErrorAction Stop
                    $PropertyName = '(default)'
                }
                else {
                    $ItemProperties = Get-ItemProperty -LiteralPath $Resource.RegistryPath -Name $Resource.ValueName -ErrorAction Stop
                    $PropertyName = $Resource.ValueName
                }

                if ($ItemProperties.PSObject.Properties.Name -contains $PropertyName) {
                    $ValueExists = $true
                    $RawValue = $ItemProperties.PSObject.Properties[$PropertyName].Value

                    if (($null -ne $RegistryKey) -and ($RegistryKey | Get-Member -Name 'GetValueKind' -MemberType Method)) {
                        $ObservedKind = [System.String]($RegistryKey.GetValueKind($Resource.ValueName))
                    }
                    else {
                        $ObservedKind = [System.String]$Resource.ValueKind
                    }

                    $ConvertedValue = ConvertTo-TargetStateRegistryValueData -ValueData $RawValue -ValueKind $ObservedKind
                    $ObservedData = $ConvertedValue.Value
                    $ObservedDisplay = $ConvertedValue.DisplayValue
                }
                else {
                    [void]$Messages.Add(('Registry value not found: {0}' -f $Resource.ValueName))
                }
            }
            catch {
                [void]$Messages.Add(('Registry value not found: {0}' -f $Resource.ValueName))
            }
        }
        else {
            [void]$Messages.Add(('Registry key not found: {0}' -f $Resource.RegistryPath))
        }

        $ObservedState = [pscustomobject][ordered]@{
            ResourceType = 'Registry'
            Name = $Resource.Name
            RegistryPath = $Resource.RegistryPath
            KeyExists = $KeyExists
            ValueExists = $ValueExists
            ValueName = $Resource.ValueName
            ValueKind = $ObservedKind
            ValueData = $ObservedData
            ValueDataDisplay = $ObservedDisplay
            Ensure = if ($ValueExists) { 'Present' } else { 'Absent' }
        }

        $Status = if ($Errors.Count -gt 0) { 'Error' } else { 'Observed' }
        New-TargetStateEvidence -Operation 'Get' -Resource $Resource -Status $Status -DesiredInput $null -ObservedState $ObservedState -Messages ([System.String[]]$Messages.ToArray()) -Errors ([System.Object[]]$Errors.ToArray()) -DocumentName $DocumentName -RunId $RunId
    }
}
