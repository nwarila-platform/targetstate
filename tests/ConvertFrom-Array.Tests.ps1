BeforeAll {
  . "$PSScriptRoot\..\src\ConvertFrom-Array.ps1"
}

Describe 'ConvertFrom-Array' {
  It 'returns a single element without a delimiter' {
    ConvertFrom-Array -Value @('alpha') | Should -Be 'alpha'
  }

  It 'joins multiple elements with comma-space delimiters' {
    ConvertFrom-Array -Value @('alpha', 'beta') | Should -Be 'alpha, beta'
  }
}
