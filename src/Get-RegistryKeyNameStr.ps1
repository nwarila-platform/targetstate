<#
Provenance:
- Source PDF: 06042026.pdf
- Rendered page images: _recovery/06042026/images/page-0006.png through page-0007.png
- Phase 2 decision: keep_A
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected malformed splat/hash punctuation around the invalid-key-name error.
- Corrected OCR quote drift around the backslash literal.
- Kept the rendered non-printable-character regex unchanged.
#>
function Get-RegistryKeyNameStr {
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
        $KeyName
    )

    process {
        $REGISTRY_KEY_NAME_EXCEPTION_HASH = @{
            ExceptionName = 'System.ArgumentException'
            ExceptionMessage = $LocalizedData.InvalidRegistryKeyNameSpecified
            ExceptionObject = $KeyName
            ErrorId = 'InvalidRegistryKeyName'
            ErrorCategory = 'InvalidArgument'
        }

        $KeyNameHasBackslash = [System.Boolean]($KeyName.Contains('\'))
        if ($KeyNameHasBackslash -eq $true) {
            ThrowError @REGISTRY_KEY_NAME_EXCEPTION_HASH
        }

        $KeyNameHasNonPrintChars = [System.Boolean]($KeyName -match '\P{Cc}\p{Cn}\p{Cs}')
        if ($KeyNameHasNonPrintChars -eq $true) {
            ThrowError @REGISTRY_KEY_NAME_EXCEPTION_HASH
        }

        $Result = [System.String]$KeyName
        $Result
    }
}
