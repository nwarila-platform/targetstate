BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'Test-TargetStateRegistryResource' {
    BeforeEach {
        $script:resource = [pscustomobject]@{
            ResourceType = 'Registry'
            Name = 'example-registry-value'
            Ensure = 'Present'
            RegistryPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TargetState\Example'
            ValueName = 'Enabled'
            ValueKind = 'DWord'
            ValueData = 1
            ValueDataDisplay = '1'
        }

        $script:mockRegistryKey = [pscustomobject]@{}
        $script:mockRegistryKey | Add-Member -MemberType ScriptMethod -Name GetValueKind -Value {
            param($Name)
            [Microsoft.Win32.RegistryValueKind]::DWord
        }
    }

    It 'returns compliant evidence when mocked registry state matches desired state' {
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 1 } }

        $evidence = Test-TargetStateRegistryResource -Resource $script:resource -DocumentName 'registry-proof' -RunId 'run-1'

        $evidence.Status | Should -Be 'Compliant'
        $evidence.InDesiredState | Should -BeTrue
        $evidence.Differences.Count | Should -Be 0
        Should -Invoke -CommandName Get-ItemProperty -Times 1 -Exactly
    }

    It 'returns noncompliant evidence when mocked registry state differs' {
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 0 } }

        $evidence = Test-TargetStateRegistryResource -Resource $script:resource -DocumentName 'registry-proof' -RunId 'run-1'

        $evidence.Status | Should -Be 'NonCompliant'
        $evidence.InDesiredState | Should -BeFalse
        $evidence.Differences[0].Action | Should -Be 'update'
        Should -Invoke -CommandName Get-ItemProperty -Times 1 -Exactly
    }
}
