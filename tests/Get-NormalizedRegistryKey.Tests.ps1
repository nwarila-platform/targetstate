BeforeAll {
  . "$PSScriptRoot\..\src\Get-NormalizedRegistryKey.ps1"
}

Describe 'Get-NormalizedRegistryKey' {
  It 'returns a registry key without normalization needs unchanged' {
    Get-NormalizedRegistryKey -RegistryKey 'HKEY_LOCAL_MACHINE\Software' |
      Should -Be 'HKEY_LOCAL_MACHINE\Software'
  }

  It 'collapses doubled backslashes' -Skip {
    Get-NormalizedRegistryKey -RegistryKey 'HKEY_LOCAL_MACHINE\\Software' |
      Should -Be 'HKEY_LOCAL_MACHINE\Software'
  }

  It 'removes a trailing backslash' -Skip {
    Get-NormalizedRegistryKey -RegistryKey 'HKEY_LOCAL_MACHINE\Software\' |
      Should -Be 'HKEY_LOCAL_MACHINE\Software'
  }
}
