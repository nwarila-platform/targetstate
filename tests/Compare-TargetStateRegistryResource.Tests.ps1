BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'Compare-TargetStateRegistryResource' {
    It 'returns no-op when observed state matches desired state' {
        $resource = [pscustomobject]@{
            Ensure = 'Present'
            ValueKind = 'DWord'
            ValueDataDisplay = '1'
        }
        $observed = [pscustomobject]@{
            KeyExists = $true
            ValueExists = $true
            ValueKind = 'DWord'
            ValueDataDisplay = '1'
        }

        $comparison = Compare-TargetStateRegistryResource -Resource $resource -ObservedState $observed

        $comparison.InDesiredState | Should -BeTrue
        $comparison.Action | Should -Be 'no-op'
        $comparison.Differences.Count | Should -Be 0
    }

    It 'plans an update when observed value data differs' {
        $resource = [pscustomobject]@{
            Ensure = 'Present'
            ValueKind = 'DWord'
            ValueDataDisplay = '1'
        }
        $observed = [pscustomobject]@{
            KeyExists = $true
            ValueExists = $true
            ValueKind = 'DWord'
            ValueDataDisplay = '0'
        }

        $comparison = Compare-TargetStateRegistryResource -Resource $resource -ObservedState $observed

        $comparison.InDesiredState | Should -BeFalse
        $comparison.Action | Should -Be 'update'
        $comparison.Differences[0].Property | Should -Be 'ValueData'
    }

    It 'plans a delete when desired state is absent and observed value exists' {
        $resource = [pscustomobject]@{
            Ensure = 'Absent'
            ValueKind = 'DWord'
            ValueDataDisplay = $null
        }
        $observed = [pscustomobject]@{
            KeyExists = $true
            ValueExists = $true
            ValueKind = 'DWord'
            ValueDataDisplay = '1'
        }

        $comparison = Compare-TargetStateRegistryResource -Resource $resource -ObservedState $observed

        $comparison.InDesiredState | Should -BeFalse
        $comparison.Action | Should -Be 'delete'
    }
}
