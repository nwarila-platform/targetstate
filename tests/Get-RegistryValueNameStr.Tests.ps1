BeforeAll {
  $script:LocalizedData = [PSCustomObject]@{
    InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
  }

  . "$PSScriptRoot\..\src\ThrowError.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryValueNameStr.ps1"
}

Describe 'Get-RegistryValueNameStr' {
  It 'returns an empty default value name unchanged' {
    Get-RegistryValueNameStr -ValueName '' | Should -Be ''
  }

  It 'returns a printable value name unchanged' {
    Get-RegistryValueNameStr -ValueName 'Setting' | Should -Be 'Setting'
  }

  It 'throws for non-printable characters' -Skip {
    { Get-RegistryValueNameStr -ValueName "Bad`0Name" } |
      Should -Throw -ExpectedMessage 'Invalid registry key name specified.'
  }
}
