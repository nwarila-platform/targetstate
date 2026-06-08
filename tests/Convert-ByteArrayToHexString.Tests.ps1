BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\Convert-ByteArrayToHexString.ps1')
}

Describe 'Convert-ByteArrayToHexString' {
    It 'formats each byte as two lowercase hex characters' {
        Convert-ByteArrayToHexString -ByteArray ([byte[]](0, 15, 16, 255)) | Should -Be '000f10ff'
    }
}
