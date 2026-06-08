BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ThrowError.ps1')
    . (Join-Path $repoRoot 'src\Get-RegistryValueKindStr.ps1')

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'Get-RegistryValueKindStr' {
    It 'parses a valid registry value kind' {
        Get-RegistryValueKindStr -ValueKind 'String' | Should -Be ([Microsoft.Win32.RegistryValueKind]::String)
    }

    It 'maps blank value kind text to RegistryValueKind None' {
        Get-RegistryValueKindStr -ValueKind '' | Should -Be ([Microsoft.Win32.RegistryValueKind]::None)
    }

    It 'throws for Unknown registry value kind text' {
        { Get-RegistryValueKindStr -ValueKind 'Unknown' } | Should -Throw
    }
}
