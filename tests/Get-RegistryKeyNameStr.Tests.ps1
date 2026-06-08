BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ThrowError.ps1')
    . (Join-Path $repoRoot 'src\Get-RegistryKeyNameStr.ps1')

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
    }
}

Describe 'Get-RegistryKeyNameStr' {
    It 'returns a key name without path separators' {
        Get-RegistryKeyNameStr -KeyName 'Vendor' | Should -Be 'Vendor'
    }

    It 'throws when the key name contains a backslash' {
        { Get-RegistryKeyNameStr -KeyName 'Vendor\Product' } | Should -Throw
    }
}
