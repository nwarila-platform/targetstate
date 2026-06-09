BeforeAll {
  . "$PSScriptRoot\..\src\ThrowError.ps1"
}

Describe 'ThrowError' {
  It 'throws a terminating error record with the supplied message and id' {
    try {
      ThrowError `
        -ExceptionName 'System.ArgumentException' `
        -ExceptionMessage 'boom' `
        -ExceptionObject 'input-value' `
        -ErrorId 'UnitTestError' `
        -ErrorCategory InvalidArgument

      throw 'ThrowError did not throw.'
    } catch {
      $_.Exception.Message | Should -Be 'boom'
      $_.FullyQualifiedErrorId | Should -Be 'UnitTestError'
      $_.CategoryInfo.Category | Should -Be 'InvalidArgument'
    }
  }
}
