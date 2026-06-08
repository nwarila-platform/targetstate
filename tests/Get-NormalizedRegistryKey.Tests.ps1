BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\Get-NormalizedRegistryKey.ps1')
}

Describe 'Get-NormalizedRegistryKey' {
    It 'returns the provided key as a string' {
        Get-NormalizedRegistryKey -RegistryKey 'HKLM\Software' | Should -Be 'HKLM\Software'
    }

    It 'preserves a trailing backslash because the recovered code trims forward slashes' {
        Get-NormalizedRegistryKey -RegistryKey 'HKLM\Software\' | Should -Be 'HKLM\Software\'
    }
}
