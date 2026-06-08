BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'Join-TargetStateRegistryPath' {
    It 'builds a Registry provider path from a hive alias and document path' {
        Join-TargetStateRegistryPath -Hive 'HKLM' -Path 'SOFTWARE\TargetState\Example' |
            Should -Be 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TargetState\Example'
    }

    It 'normalizes forward slashes in the document path' {
        Join-TargetStateRegistryPath -Hive 'HKEY_CURRENT_USER' -Path 'Software/TargetState' |
            Should -Be 'Registry::HKEY_CURRENT_USER\Software\TargetState'
    }
}
