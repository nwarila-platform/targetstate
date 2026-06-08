BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    Get-ChildItem (Join-Path $repoRoot 'src\*.ps1') | Sort-Object Name | ForEach-Object { . $PSItem.FullName }

    $script:LocalizedData = [pscustomobject]@{
        InvalidRegistryHiveSpecified = 'Invalid registry hive specified: {0}'
        InvalidRegistryKeyNameSpecified = 'Invalid registry key name specified.'
        InvalidRegistryValueTypeSpecified = 'Invalid registry value type specified.'
    }
}

Describe 'Import-TargetStateDocument' {
    It 'loads and validates a JSON TargetDocument' {
        $json = @'
{
  "apiVersion": "targetstate.nwarila.dev/v1alpha1",
  "kind": "TargetDocument",
  "metadata": { "name": "registry-proof" },
  "resources": [
    {
      "type": "Registry",
      "name": "example-registry-value",
      "properties": {
        "hive": "HKLM",
        "path": "SOFTWARE\\TargetState\\Example",
        "valueName": "Enabled",
        "valueKind": "DWord",
        "valueData": 1,
        "ensure": "Present"
      }
    }
  ]
}
'@

        $document = Import-TargetStateDocument -Json $json

        $document.Kind | Should -Be 'TargetDocument'
        $document.Metadata.Name | Should -Be 'registry-proof'
        $document.Resources.Count | Should -Be 1
        $document.Resources[0].RegistryPath | Should -Be 'Registry::HKEY_LOCAL_MACHINE\SOFTWARE\TargetState\Example'
    }

    It 'rejects unsupported document kinds through ThrowError' {
        $json = '{ "apiVersion": "targetstate.nwarila.dev/v1alpha1", "kind": "Other", "metadata": { "name": "bad" }, "resources": [] }'

        { Import-TargetStateDocument -Json $json } | Should -Throw
    }
}
