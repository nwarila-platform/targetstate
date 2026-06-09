BeforeAll {
  $script:LocalizedData = [PSCustomObject]@{
    InvalidRegistryHiveSpecified = 'Invalid registry hive specified.'
    InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
    InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    ParameterRequired = 'Missing required property: {0}'
  }

  . "$PSScriptRoot\..\src\ThrowError.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryKeyHiveObj.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryKeyNameStr.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryKeyPathStr.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryValueNameStr.ps1"
  . "$PSScriptRoot\..\src\Get-RegistryValueKindStr.ps1"
  . "$PSScriptRoot\..\src\Mount-RegistryHive.ps1"
  . "$PSScriptRoot\..\src\Start-ProviderSetup.ps1"
}

Describe 'Start-ProviderSetup' {
  BeforeEach {
    Mock Mount-RegistryHive { }
  }

  It 'returns the normalized setup object for a valid declaration' {
    $inputObject = [PSCustomObject]@{
      KeyHive = 'HKLM'
      KeyPath = 'Software\Vendor'
      KeyName = 'Example'
      ValueName = 'Enabled'
      ValueKind = 'DWord'
      ValueData = '1'
    }

    $result = Start-ProviderSetup -InputObject $inputObject

    $result.RegistryKeyHive.Name | Should -Be 'HKEY_LOCAL_MACHINE'
    $result.RegistryKeyHive.ShortName | Should -Be 'LocalMachine'
    $result.RegistryKeyHive.Abbreviation | Should -Be 'HKLM'
    $result.RegistryKeyPath | Should -Be 'Software\Vendor'
    $result.RegistryKeyName | Should -Be 'Example'
    $result.RegistryValueName | Should -Be 'Enabled'
    $result.RegistryValueKind | Should -Be ([Microsoft.Win32.RegistryValueKind]::DWord)
    $result.RegistryValueData | Should -Be '1'

    Should -Invoke Mount-RegistryHive -Times 1 -Exactly -ParameterFilter {
      $RegistryHive.Name -eq 'HKEY_LOCAL_MACHINE' -and
      $RegistryHive.Abbreviation -eq 'HKLM'
    }
  }

  It 'throws a structured ParameterRequired error for a missing required property' {
    $inputObject = [PSCustomObject]@{
      KeyName = 'Example'
    }

    Try {
      Start-ProviderSetup -InputObject $inputObject
      Throw 'Start-ProviderSetup did not throw.'
    } Catch {
      $_.FullyQualifiedErrorId | Should -Be 'ParameterRequired'
      $_.Exception.Message | Should -Be 'Missing required property: KeyHive'
      $_.TargetObject | Should -Be 'KeyHive'
    }

    Should -Invoke Mount-RegistryHive -Times 0 -Exactly
  }

  It 'warns for an unexpected property and continues' {
    Mock Write-Warning { }
    $inputObject = [PSCustomObject]@{
      KeyHive = 'HKLM'
      KeyName = 'Example'
      Surprise = 'present'
    }

    { Start-ProviderSetup -InputObject $inputObject } | Should -Not -Throw

    Should -Invoke Write-Warning -Times 1 -Exactly -ParameterFilter {
      $Message -eq "Unexpected Property:  'Surprise'"
    }
    Should -Invoke Mount-RegistryHive -Times 1 -Exactly
  }
}
