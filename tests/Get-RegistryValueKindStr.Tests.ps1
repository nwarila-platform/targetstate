BeforeAll {
  $script:LocalizedData = [PSCustomObject]@{
    InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
  }

  Function ThrowError {
    [CmdletBinding()]
    Param(
      [System.String]
      $ErrorId,
      [System.Management.Automation.ErrorCategory]
      $ErrorCategory,
      [System.String]
      $ExceptionName,
      [System.Object]
      $ExceptionObject,
      [System.String]
      $ExceptionMessage
    )
    throw $ExceptionMessage
  }

  . "$PSScriptRoot\..\src\Get-RegistryValueKindStr.ps1"
}

Describe 'Get-RegistryValueKindStr' {
  It 'returns None for an empty value kind' {
    Get-RegistryValueKindStr -ValueKind '' | Should -Be ([Microsoft.Win32.RegistryValueKind]::None)
  }

  It 'returns None for a whitespace value kind' {
    Get-RegistryValueKindStr -ValueKind '   ' | Should -Be ([Microsoft.Win32.RegistryValueKind]::None)
  }

  It 'returns the parsed registry value kind for a valid value kind string' {
    Get-RegistryValueKindStr -ValueKind 'DWord' | Should -Be ([Microsoft.Win32.RegistryValueKind]::DWord)
  }

  It 'throws for an invalid value kind string' {
    { Get-RegistryValueKindStr -ValueKind 'DefinitelyNotARegistryKind' } |
      Should -Throw -ExpectedMessage 'Invalid registry value type specified.'
  }

  It 'throws for Unknown even though the enum parser accepts it' {
    { Get-RegistryValueKindStr -ValueKind 'Unknown' } |
      Should -Throw -ExpectedMessage 'Invalid registry value type specified.'
  }
}
