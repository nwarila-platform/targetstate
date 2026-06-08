<#
Provenance:
- Source PDF: 06042026_001.pdf
- Rendered page images: _recovery/06042026_001/images/page-0005.png through page-0006.png
- Phase 2 decision: keep_B
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected splat marker drift around the registry-hive exception hash.
- Corrected lowercase OCR variants only where the rendered image showed switch regex alternatives.
- Corrected namespace / enum spacing in the error-category value.
#>
function Get-RegistryKeyHive {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Default',
        PositionalBinding = $true
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 0,
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RegistryKey
    )

    process {
        $REGISTRY_HIVE_EXCEPTION_HASH = @{
            ExceptionName = 'System.ArgumentException'
            ExceptionMessage = $LocalizedData.InvalidRegistryHiveSpecified -f $RegistryKey
            ExceptionObject = $RegistryKey
            ErrorId = 'InvalidRegistryHive'
            ErrorCategory = 'InvalidArgument'
        }

        $RegistryHive = [System.String]$RegistryKey
        $HasBackslash = [System.Boolean]($RegistryHive.Contains('\') -eq $true)
        if ($HasBackslash -eq $true) {
            $RegistryHive = $RegistryHive.Split('\')[0]
        }

        switch -Regex ($RegistryHive) {
            '^(hkey_classes_root|hkcr)$' {
                $RegistryHive = 'HKEY_CLASSES_ROOT'
            }
            '^(hkey_current_user|hkcu)$' {
                $RegistryHive = 'HKEY_CURRENT_USER'
            }
            '^(hkey_local_machine|hklm)$' {
                $RegistryHive = 'HKEY_LOCAL_MACHINE'
            }
            '^(hkey_users|hkus)$' {
                $RegistryHive = 'HKEY_USERS'
            }
            '^(hkey_current_config|hkcc)$' {
                $RegistryHive = 'HKEY_CURRENT_CONFIG'
            }
            default {
                ThrowError @REGISTRY_HIVE_EXCEPTION_HASH
            }
        }

        $Result = [System.String]$RegistryHive
        $Result
    }
}
