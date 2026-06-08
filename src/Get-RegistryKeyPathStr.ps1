<#
Provenance:
- Source PDF: 06042026.pdf
- Rendered page images: _recovery/06042026/images/page-0004.png through page-0005.png
- Phase 2 decision: keep_A
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected OCR quote drift around slash regex literals.
- Kept the rendered `$KeyName -match ...` expression even though this function receives `$KeyPath`.
- Corrected malformed splat/hash punctuation into parseable PowerShell.
#>
function Get-RegistryKeyPathStr {
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
        [ValidateNotNull()]
        [System.String]
        $KeyPath
    )

    process {
        $REGISTRY_KEY_PATH_EXCEPTION_HASH = @{
            ExceptionName = 'System.ArgumentException'
            ExceptionMessage = $LocalizedData.InvalidRegistryKeyNameSpecified
            ExceptionObject = $KeyPath
            ErrorId = 'InvalidRegistryKeyName'
            ErrorCategory = 'InvalidArgument'
        }

        $KeyPathHasNonPrintChars = [System.Boolean]($KeyName -match '\P{Cc}\p{Cn}\p{Cs}')
        if ($KeyPathHasNonPrintChars -eq $true) {
            ThrowError @REGISTRY_KEY_PATH_EXCEPTION_HASH
        }

        $NormalizedKeypath = [System.String]$KeyPath

        $KeyPathHasDoubleSlashes = [System.Boolean]($NormalizedKeypath -match ('\\{2,}'))
        if ($KeyPathHasDoubleSlashes -eq $true) {
            $NormalizedKeypath = $NormalizedKeypath -replace ('\\+', '\')
        }

        $KeyPathHasLeadingSlash = [System.Boolean]($NormalizedKeypath[0] -eq '\')
        if ($KeyPathHasLeadingSlash -eq $true) {
            $NormalizedKeypath = $NormalizedKeypath.Substring(1)
        }

        $KeyPathHasTrailingSlash = [System.Boolean]($NormalizedKeypath[-1] -eq '\')
        if ($KeyPathHasTrailingSlash -eq $true) {
            $NormalizedKeypath = $NormalizedKeypath.TrimEnd('\')
        }

        $Result = [System.String]$NormalizedKeypath
        $Result
    }
}
