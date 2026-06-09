BeforeAll {
  $script:LocalizedData = [PSCustomObject]@{
    InvalidRegistryHiveSpecified = 'Invalid registry hive specified.'
  }

  . "$PSScriptRoot\..\src\ThrowError.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryKeyHiveObj.ps1"
}

Describe 'Get-RegistryKeyHiveObj' {
  It 'returns the hive descriptor for a full hive name' {
    $result = Get-RegistryKeyHiveObj -KeyHive 'HKEY_LOCAL_MACHINE'

    $result.Name | Should -Be 'HKEY_LOCAL_MACHINE'
    $result.ShortName | Should -Be 'LocalMachine'
    $result.Abbreviation | Should -Be 'HKLM'
  }

  It 'returns the hive descriptor for the HKCR full hive name' {
    $result = Get-RegistryKeyHiveObj -KeyHive 'HKEY_CLASSES_ROOT'

    $result.Name | Should -Be 'HKEY_CLASSES_ROOT'
    $result.ShortName | Should -Be 'ClassesRoot'
    $result.Abbreviation | Should -Be 'HKCR'
  }

  It 'throws for an invalid hive' {
    { Get-RegistryKeyHiveObj -KeyHive 'NOPE' } |
      Should -Throw -ExpectedMessage 'Invalid registry hive specified.'
  }

  It 'returns the hive descriptor for an abbreviated hive alias' {
    $result = Get-RegistryKeyHiveObj -KeyHive 'HKLM'

    $result.Name | Should -Be 'HKEY_LOCAL_MACHINE'
    $result.ShortName | Should -Be 'LocalMachine'
    $result.Abbreviation | Should -Be 'HKLM'
  }
}
