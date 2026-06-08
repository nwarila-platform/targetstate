<#
Design:
- Phase 6 fresh TargetState Registry resource validator; not recovered source.
- Converts one JSON resource object into the read-only Registry proof contract.
- Uses recovered Registry normalizers for hive, key, value name, and value kind inputs.
#>
function ConvertTo-TargetStateRegistryResource {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Default',
        PositionalBinding = $true
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 0,
            ValueFromPipeline = $true
        )]
        [ValidateNotNull()]
        [System.Object]
        $Resource
    )

    begin {
        function Test-TargetStateProperty {
            param(
                [Parameter(Mandatory = $true)]
                [AllowNull()]
                [System.Object]
                $InputObject,

                [Parameter(Mandatory = $true)]
                [System.String]
                $Name
            )

            ($null -ne $InputObject) -and ($InputObject.PSObject.Properties.Name -contains $Name)
        }

        function Invoke-TargetStateValidationError {
            param(
                [Parameter(Mandatory = $true)]
                [System.String]
                $Message,

                [Parameter(Mandatory = $true)]
                [System.String]
                $ErrorId,

                [Parameter(Mandatory = $false)]
                [AllowNull()]
                [System.Object]
                $TargetObject
            )

            ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $Message -ExceptionObject $TargetObject -ErrorId $ErrorId -ErrorCategory 'InvalidArgument'
        }
    }

    process {
        if (-not (Test-TargetStateProperty -InputObject $Resource -Name 'type')) {
            Invoke-TargetStateValidationError -Message 'Registry resource is missing type.' -ErrorId 'TargetStateRegistryResourceMissingType' -TargetObject $Resource
        }

        if ([System.String]$Resource.type -ne 'Registry') {
            Invoke-TargetStateValidationError -Message ('Unsupported resource type: {0}' -f $Resource.type) -ErrorId 'TargetStateUnsupportedResourceType' -TargetObject $Resource
        }

        if (-not (Test-TargetStateProperty -InputObject $Resource -Name 'name')) {
            Invoke-TargetStateValidationError -Message 'Registry resource is missing name.' -ErrorId 'TargetStateRegistryResourceMissingName' -TargetObject $Resource
        }

        if (-not (Test-TargetStateProperty -InputObject $Resource -Name 'properties')) {
            Invoke-TargetStateValidationError -Message 'Registry resource is missing properties.' -ErrorId 'TargetStateRegistryResourceMissingProperties' -TargetObject $Resource
        }

        $Properties = $Resource.properties
        foreach ($RequiredProperty in @('hive', 'path', 'valueName', 'valueKind', 'ensure')) {
            if (-not (Test-TargetStateProperty -InputObject $Properties -Name $RequiredProperty)) {
                Invoke-TargetStateValidationError -Message ('Registry resource is missing properties.{0}.' -f $RequiredProperty) -ErrorId 'TargetStateRegistryPropertyMissing' -TargetObject $Resource
            }
        }

        $Ensure = [System.String]$Properties.ensure
        if ($Ensure -notin @('Present', 'Absent')) {
            Invoke-TargetStateValidationError -Message ('Unsupported Ensure value: {0}' -f $Ensure) -ErrorId 'TargetStateRegistryEnsureInvalid' -TargetObject $Resource
        }

        if (($Ensure -eq 'Present') -and (-not (Test-TargetStateProperty -InputObject $Properties -Name 'valueData'))) {
            Invoke-TargetStateValidationError -Message 'Present Registry resources require properties.valueData.' -ErrorId 'TargetStateRegistryValueDataMissing' -TargetObject $Resource
        }

        $Hive = Get-RegistryKeyHive -RegistryKey ([System.String]$Properties.hive)
        $Path = [System.String]$Properties.path
        $NormalizedKey = Get-NormalizedRegistryKey -RegistryKey ('{0}{1}{2}' -f $Hive, [System.Char]92, $Path)
        $ValueName = Get-RegistryValueNameStr -ValueName ([System.String]$Properties.valueName)
        $ValueKind = Get-RegistryValueKindStr -ValueKind ([System.String]$Properties.valueKind)
        $ValueData = $null
        if (Test-TargetStateProperty -InputObject $Properties -Name 'valueData') {
            $ValueData = ConvertTo-TargetStateRegistryValueData -ValueData $Properties.valueData -ValueKind $ValueKind
        }

        [pscustomobject][ordered]@{
            ResourceType = 'Registry'
            Name = [System.String]$Resource.name
            Ensure = $Ensure
            Hive = $Hive
            Path = $Path
            NormalizedKey = $NormalizedKey
            RegistryPath = Join-TargetStateRegistryPath -Hive $Hive -Path $Path
            ValueName = $ValueName
            ValueKind = [System.String]$ValueKind
            ValueData = $ValueData.Value
            ValueDataDisplay = $ValueData.DisplayValue
        }
    }
}
