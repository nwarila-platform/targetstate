<#
Provenance:
- Source PDF: 06042026_001.pdf
- Rendered page image: _recovery/06042026_001/images/page-0010.png
- Phase 2 decision: keep_B
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected OCR sigils around `$Result`.
- Corrected smart quote / spacing drift around the format string.
- Kept the visible TODO marker and append-loop behavior; no typed input narrowing was added.
#>
function Convert-ByteArrayToHexString {
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
        [object]
        $ByteArray
    )

    begin {
        $Result = [System.String]::Empty
    }

    process {
        # !TODO
        $ByteArray | ForEach-Object -Process {
            $Result += [System.String]::Format('{0:x2}', $_)
        }

        ([System.String]$Result)
    }
}
