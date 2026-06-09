BeforeAll {
  . "$PSScriptRoot\..\src\ThrowError.ps1"
  . "$PSScriptRoot\..\src\Mount-RegistryHive.ps1"
}

Describe 'Mount-RegistryHive' {
  BeforeEach {
    $script:RegistryHive = @{
      Name = 'HKEY_LOCAL_MACHINE'
      Abbreviation = 'HKLM'
    }
    $script:TestPathCallIndex = 0
    $script:TestPathResults = @($True)

    Mock Test-Path {
      $result = $script:TestPathResults[$script:TestPathCallIndex]
      $script:TestPathCallIndex += 1
      $result
    }
    Mock New-PSDrive { }
  }

  It 'does not mount an already mounted hive' {
    $script:TestPathResults = @($True, $True)

    Mount-RegistryHive -RegistryHive $script:RegistryHive

    Should -Invoke Test-Path -Times 2 -Exactly
    Should -Invoke New-PSDrive -Times 0 -Exactly
  }

  It 'mounts an unmounted hive and verifies it is mounted' {
    $script:TestPathResults = @($False, $True)

    Mount-RegistryHive -RegistryHive $script:RegistryHive

    Should -Invoke Test-Path -Times 2 -Exactly
    Should -Invoke New-PSDrive -Times 1 -Exactly -ParameterFilter {
      $Name -eq 'HKLM' -and
      $PSProvider -eq 'Registry' -and
      $Scope -eq 'Script' -and
      $Root -eq 'HKEY_LOCAL_MACHINE'
    }
  }

  It 'throws a structured error when the hive cannot be mounted' {
    $script:TestPathResults = @($False, $False)

    Try {
      Mount-RegistryHive -RegistryHive $script:RegistryHive
      Throw 'Mount-RegistryHive did not throw.'
    } Catch {
      $_.FullyQualifiedErrorId | Should -Be 'RegistryHiveMountFailed'
      $_.Exception.GetType().FullName | Should -Be 'System.IO.IOException'
    }

    Should -Invoke Test-Path -Times 2 -Exactly
    Should -Invoke New-PSDrive -Times 1 -Exactly
  }

  It 'does not mount when WhatIf prevents ShouldProcess' {
    $script:TestPathResults = @($False, $True)

    Mount-RegistryHive -RegistryHive $script:RegistryHive -WhatIf

    Should -Invoke Test-Path -Times 2 -Exactly
    Should -Invoke New-PSDrive -Times 0 -Exactly
  }
}
