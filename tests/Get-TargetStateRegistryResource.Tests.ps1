BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'Get-TargetStateRegistryResource' {
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

    It 'returns observed evidence when mocked registry state contains the value' {
        Mock -CommandName Test-Path -MockWith { $true }
        Mock -CommandName Get-Item -MockWith { $script:mockRegistryKey }
        Mock -CommandName Get-ItemProperty -MockWith { [pscustomobject]@{ Enabled = 1 } }

        $evidence = Get-TargetStateRegistryResource -Resource $script:resource -DocumentName 'registry-proof' -RunId 'run-1'

        $evidence.Status | Should -Be 'Observed'
        $evidence.ObservedState.KeyExists | Should -BeTrue
        $evidence.ObservedState.ValueExists | Should -BeTrue
        $evidence.ObservedState.ValueData | Should -Be 1
        Should -Invoke -CommandName Test-Path -Times 1 -Exactly
        Should -Invoke -CommandName Get-ItemProperty -Times 1 -Exactly
    }

    It 'returns observed evidence when mocked registry state is absent' {
        Mock -CommandName Test-Path -MockWith { $false }
        Mock -CommandName Get-Item -MockWith { throw 'Get-Item should not be called' }
        Mock -CommandName Get-ItemProperty -MockWith { throw 'Get-ItemProperty should not be called' }

        $evidence = Get-TargetStateRegistryResource -Resource $script:resource -DocumentName 'registry-proof' -RunId 'run-1'

        $evidence.Status | Should -Be 'Observed'
        $evidence.ObservedState.KeyExists | Should -BeFalse
        $evidence.ObservedState.ValueExists | Should -BeFalse
        Should -Invoke -CommandName Test-Path -Times 1 -Exactly
        Should -Invoke -CommandName Get-ItemProperty -Times 0 -Exactly
    }
}
