BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ThrowError.ps1')
    . (Join-Path $repoRoot 'src\Get-RegistryKeyPathStr.ps1')

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
    }
}

Describe 'Get-RegistryKeyPathStr' {
    It 'normalizes doubled, leading, and trailing backslashes' {
        $keyPath = '\SOFTWARE\' + '\Vendor\'
        Get-RegistryKeyPathStr -KeyPath $keyPath | Should -Be 'SOFTWARE\Vendor'
    }
}
