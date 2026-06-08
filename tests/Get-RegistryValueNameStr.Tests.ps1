BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ThrowError.ps1')
    . (Join-Path $repoRoot 'src\Get-RegistryValueNameStr.ps1')

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
    }
}

Describe 'Get-RegistryValueNameStr' {
    It 'returns the provided value name' {
        Get-RegistryValueNameStr -ValueName 'InstallPath' | Should -Be 'InstallPath'
    }

    It 'allows an empty value name' {
        Get-RegistryValueNameStr -ValueName '' | Should -Be ''
    }
}
