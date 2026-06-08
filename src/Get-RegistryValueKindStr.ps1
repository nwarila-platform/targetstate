<#
Provenance:
- Source PDF: 06042026.pdf
- Rendered page images: _recovery/06042026/images/page-0008.png through page-0009.png
- Phase 2 decision: keep_A
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected enum type spacing and ref syntax around `RegistryValueKind`.
- Used a case-sensitive `Enum.Parse`/catch equivalent because this Windows PowerShell 5.1 runtime exposes only generic `Enum.TryParse` overloads that cannot be called from this syntax.
- Corrected malformed exception hash / splat punctuation.
- Kept the rendered Unknown-value rejection behavior.
#>
function Get-RegistryValueKindStr {
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
        [AllowEmptyString()]
        [ValidateNotNull()]
        [System.String]
        $ValueKind
    )

    process {
        $REGISTRY_VALUE_KIND_EXCEPTION_HASH = @{
            ExceptionName = 'System.ArgumentException'
            ExceptionMessage = $LocalizedData.InvalidRegistryValueTypeSpecified
            ExceptionObject = $ValueKind
            ErrorId = 'InvalidRegistryValueTypeSpecified'
            ErrorCategory = 'InvalidArgument'
        }

        if ([System.String]::IsNullOrWhiteSpace($ValueKind)) {
            $NormalizedValueKind = [Microsoft.Win32.RegistryValueKind]::None
        }
        else {
            try {
                $NormalizedValueKind = [Microsoft.Win32.RegistryValueKind](
                    [System.Enum]::Parse([Microsoft.Win32.RegistryValueKind], $ValueKind, $false)
                )
                $IsValidValueKind = $true
            }
            catch {
                $NormalizedValueKind = [Microsoft.Win32.RegistryValueKind]::None
                $IsValidValueKind = $false
            }
        }

        $ValueKindIsUnknown = [System.Boolean]($NormalizedValueKind -eq 'Unknown')
        if (($IsValidValueKind -eq $false) -or ($ValueKindIsUnknown -eq $true)) {
            ThrowError @REGISTRY_VALUE_KIND_EXCEPTION_HASH
        }

        $Result = [Microsoft.Win32.RegistryValueKind]$NormalizedValueKind
        $Result
    }
}
