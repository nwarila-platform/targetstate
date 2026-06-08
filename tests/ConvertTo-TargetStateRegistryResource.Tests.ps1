BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'ConvertTo-TargetStateRegistryResource' {
    It 'validates and normalizes a Registry resource' {
        $resource = [pscustomobject]@{
            type = 'Registry'
            name = 'example-registry-value'
            properties = [pscustomobject]@{
                hive = 'HKLM'
                path = 'SOFTWARE\TargetState\Example'
                valueName = 'Enabled'
                valueKind = 'DWord'
                valueData = 1
                ensure = 'Present'
            }
        }

        $result = ConvertTo-TargetStateRegistryResource -Resource $resource

        $result.ResourceType | Should -Be 'Registry'
        $result.Hive | Should -Be 'HKEY_LOCAL_MACHINE'
        $result.RegistryPath | Should -Be 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TargetState\Example'
        $result.ValueKind | Should -Be 'DWord'
        $result.ValueData | Should -Be 1
    }

    It 'rejects unknown resource types through ThrowError' {
        $resource = [pscustomobject]@{
            type = 'File'
            name = 'wrong-kind'
            properties = [pscustomobject]@{}
        }

        { ConvertTo-TargetStateRegistryResource -Resource $resource } | Should -Throw
    }
}
