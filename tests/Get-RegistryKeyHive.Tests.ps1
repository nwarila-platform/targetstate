BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ThrowError.ps1')
    . (Join-Path $repoRoot 'src\Get-RegistryKeyHive.ps1')

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
    }
}

Describe 'Get-RegistryKeyHive' {
    It 'normalizes HKLM aliases to the full hive name' {
        Get-RegistryKeyHive -RegistryKey 'HKLM\Software' | Should -Be 'HKEY_LOCAL_MACHINE'
    }

    It 'throws for an unknown hive' {
        { Get-RegistryKeyHive -RegistryKey 'NOPE\Software' } | Should -Throw
    }
}
