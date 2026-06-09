BeforeAll {
  $script:LocalizedData = [PSCustomObject]@{
    InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
  }

  . "$PSScriptRoot\..\src\ThrowError.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryKeyNameStr.ps1"
}

Describe 'Get-RegistryKeyNameStr' {
  It 'returns a printable key name unchanged' {
    Get-RegistryKeyNameStr -KeyName 'Vendor' | Should -Be 'Vendor'
  }

  It 'throws when the key name contains a backslash' {
    { Get-RegistryKeyNameStr -KeyName 'Bad\Name' } |
      Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
  }

  It 'throws for non-printable characters' {
    { Get-RegistryKeyNameStr -KeyName "Bad`0Name" } |
      Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
  }
}
