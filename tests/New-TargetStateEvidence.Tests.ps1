BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'New-TargetStateEvidence' {
    It 'builds read-only ADR 0005 evidence with mutation flags false' {
        $resource = [pscustomobject]@{
            ResourceType = 'Registry'
            Name = 'example'
            RegistryPath = 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TargetState'
            ValueName = 'Enabled'
        }

        $result = New-TargetStateEvidence -Operation 'Get' -Resource $resource -Status 'Observed' -DocumentName 'registry-proof' -RunId 'run-1'

        $result.RunId | Should -Be 'run-1'
        $result.Operation | Should -Be 'Get'
        $result.Resource.Type | Should -Be 'Registry'
        $result.Mutation.Attempted | Should -BeFalse
        $result.Mutation.Changed | Should -BeFalse
    }
}
