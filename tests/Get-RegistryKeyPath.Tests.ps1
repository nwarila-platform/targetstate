BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\Get-RegistryKeyPath.ps1')
}

Describe 'Get-RegistryKeyPath' {
    It 'extracts the path between the hive and final key name' {
        Get-RegistryKeyPath -RegistryKey 'HKLM\Software\Vendor\Product' | Should -Be 'Software\Vendor'
    }

    It 'returns an empty string when no intermediate path exists' {
        Get-RegistryKeyPath -RegistryKey 'HKLM\Software' | Should -Be ''
    }

    It 'accepts pipeline input' {
        'HKCU\Control Panel\Desktop' | Get-RegistryKeyPath | Should -Be 'Control Panel'
    }
}
