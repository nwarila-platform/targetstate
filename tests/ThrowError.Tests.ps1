BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    . (Join-Path $repoRoot 'src\ThrowError.ps1')
}

Describe 'ThrowError' {
    It 'throws an ErrorRecord with the supplied id and category' {
        $caught = $null

        try {
            ThrowError `
                -ExceptionName 'System.ArgumentException' `
                -ExceptionMessage 'bad input' `
                -ExceptionObject 'subject' `
                -ErrorId 'Phase3TestError' `
                -ErrorCategory InvalidArgument
        }
        catch {
            $caught = $_
        }

        $caught | Should -Not -BeNullOrEmpty
        $caught.FullyQualifiedErrorId | Should -Be 'Phase3TestError'
        $caught.CategoryInfo.Category | Should -Be ([System.Management.Automation.ErrorCategory]::InvalidArgument)
    }
}
