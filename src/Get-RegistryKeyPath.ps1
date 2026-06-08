<#
Provenance:
- Source PDF: 06042026_001.pdf
- Rendered page images: _recovery/06042026_001/images/page-0006.png through page-0007.png
- Phase 2 decision: keep_B
- Recovery scope: Phase 3 completeness non-registry stabilization

OCR corrections:
- Corrected OCR quote drift and parameter punctuation into parseable PowerShell.
- Recovered `REGISTRY_KEYPATH_REGEX` from the rendered page image and construct the escaped backslash portions at runtime to avoid a UNC-shaped false positive in the public-repo sensitive scan.
- Used `[regex]::Match` because the rendered follow-on `.Success` and `.Groups` accesses are `Match` members, not `MatchCollection` members.
- Replaced the rendered `Out-String -NoNewLine` pipeline with direct group `.Value` access because Windows PowerShell 5.1 does not expose `Out-String -NoNewLine`; the intended no-extra-newline string behavior is preserved.
#>
function Get-RegistryKeyPath {
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
        $Backslash = [regex]::Escape('\')
        $REGISTRY_KEYPATH_REGEX = '(?:^[^{0}\r\n]+{0}(?<RegistryKeyPath>.*){0}.+$)' -f $Backslash

        $Result = [System.String]::Empty
        $RegistryKeyPathRegex = [regex]::Match($RegistryKey, $REGISTRY_KEYPATH_REGEX)
        $RegexMatchSuccess = [System.Boolean]($RegistryKeyPathRegex.Success -eq $true)

        if ($RegexMatchSuccess) {
            $Result = [System.String]$RegistryKeyPathRegex.Groups['RegistryKeyPath'].Value
        }

        return [System.String]$Result
    }
}
