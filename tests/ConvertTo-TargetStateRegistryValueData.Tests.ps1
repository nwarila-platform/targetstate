BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'ConvertTo-TargetStateRegistryValueData' {
    It 'normalizes DWord values to comparable integers' {
        $result = ConvertTo-TargetStateRegistryValueData -ValueData '1' -ValueKind 'DWord'

        $result.Kind | Should -Be 'DWord'
        $result.Value | Should -Be 1
        $result.DisplayValue | Should -Be '1'
    }

    It 'normalizes byte arrays to lowercase hex for evidence' {
        $result = ConvertTo-TargetStateRegistryValueData -ValueData ([byte[]](1, 255)) -ValueKind 'Binary'

        $result.Value | Should -Be '01ff'
        $result.DisplayValue | Should -Be '01ff'
    }

    It 'keeps MultiString values as string arrays with stable display text' {
        $result = ConvertTo-TargetStateRegistryValueData -ValueData @('alpha', 'beta') -ValueKind 'MultiString'

        $result.Value | Should -Be @('alpha', 'beta')
        $result.DisplayValue | Should -Be 'alpha, beta'
    }
}
