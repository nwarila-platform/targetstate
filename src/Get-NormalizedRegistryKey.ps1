<#
Provenance:
- Source PDF: 06042026_001.pdf
- Rendered page images: _recovery/06042026_001/images/page-0004.png through page-0005.png
- Phase 2 decision: keep_B
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected OCR quote drift around slash literals.
- Kept the rendered `-contains` operator and `TrimEnd('/')` behavior exactly, even though the comments imply backslash normalization.
- Corrected malformed parameter punctuation into parseable PowerShell without adding new logic.
#>
function Get-NormalizedRegistryKey {
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
        $RegistryKeyStr = [System.String]$RegistryKey

        $HasDoubleSlashes = [System.Boolean]($RegistryKeyStr -contains ('\\'))
        if ($HasDoubleSlashes -eq $true) {
            $RegistryKeyStr = $RegistryKeyStr -replace ('\\+', '\')
        }

        $HasTrailingSlash = [System.Boolean]($RegistryKeyStr.EndsWith('\'))
        if ($HasTrailingSlash -eq $true) {
            $RegistryKeyStr = $RegistryKeyStr.TrimEnd('/')
        }

        $Result = [System.String]$RegistryKeyStr
        $Result
    }
}
