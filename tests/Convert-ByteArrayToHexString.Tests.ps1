BeforeAll {
  . "$PSScriptRoot\..\src\Convert-ByteArrayToHexString.ps1"
}

Describe 'Convert-ByteArrayToHexString' {
  It 'converts bytes to lowercase two-character hex values' {
    Convert-ByteArrayToHexString -ByteArray ([byte[]](0, 15, 255)) | Should -Be '000fff'
  }

  It 'converts a single byte value' {
    Convert-ByteArrayToHexString -ByteArray 10 | Should -Be '0a'
  }
}
