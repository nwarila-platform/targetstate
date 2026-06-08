<#
Provenance:
- Source PDF: 06042026.pdf
- Rendered page images: _recovery/06042026/images/page-0007.png through page-0008.png
- Phase 2 decision: keep_A
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected malformed `AllowEmptyString` and validation attribute casing.
- Corrected exception hash / splat punctuation.
- Kept the rendered non-printable-character regex unchanged.
#>
function Get-RegistryValueNameStr {
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
        $ValueName
    )

    process {
        $REGISTRY_VALUE_NAME_EXCEPTION_HASH = @{
            ExceptionName = 'System.ArgumentException'
            ExceptionMessage = $LocalizedData.InvalidRegistryKeyNameSpecified
            ExceptionObject = $ValueName
            ErrorId = 'InvalidRegistryKeyName'
            ErrorCategory = 'InvalidArgument'
        }

        $IsNonPrintable = [System.Boolean]($ValueName -match '\P{Cc}\p{Cn}\p{Cs}')
        if ($IsNonPrintable -eq $true) {
            ThrowError @REGISTRY_VALUE_NAME_EXCEPTION_HASH
        }

        $Result = [System.String]$ValueName
        $Result
    }
}
