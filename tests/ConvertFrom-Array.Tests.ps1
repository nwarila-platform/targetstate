BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ConvertFrom-Array.ps1')
}

Describe 'ConvertFrom-Array' {
    It 'joins string array values with comma-space separators' {
        ConvertFrom-Array -Value @('alpha', 'beta', 'gamma') | Should -Be 'alpha, beta, gamma'
    }

    It 'returns an empty string for an empty string array' {
        ConvertFrom-Array -Value ([string[]]@()) | Should -Be ''
    }
}
