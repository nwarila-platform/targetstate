BeforeAll {
  $script:LocalizedData = [PSCustomObject]@{
    InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
  }

  . "$PSScriptRoot\..\src\ThrowError.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryKeyPathStr.ps1"
}

Describe 'Get-RegistryKeyPathStr' {
  It 'normalizes doubled, leading, and trailing backslashes' {
    Get-RegistryKeyPathStr -KeyPath '\Software\\Vendor\' | Should -Be 'Software\Vendor'
  }

  It 'throws for non-printable characters' {
    { Get-RegistryKeyPathStr -KeyPath "Software`0Vendor" } |
      Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
  }
}
