<#
Provenance:
- Source PDF: 06042026.pdf
- Rendered page images: _recovery/06042026/images/page-0015.png through page-0017.png
- Phase 2 decision: keep_A
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected OCR `Q` digits to `0` in positional arguments and range bounds.
- Corrected OCR `ae =` to `$Null =` on the StringBuilder append line.
- Corrected smart quotes and malformed `a(` tokens to parseable ASCII quotes and `@(`.
- Excluded the active-development scratch block after the function end on page 0017.
#>
function ConvertFrom-Array {
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
        [AllowEmptyCollection()]
        [ValidateNotNull()]
        [System.String[]]
        $Value
    )

    begin {
        Write-Debug -Message:'Entering Block: Begin'

        New-Variable -Force -Option:'Private' -Name:'Result' -Value:([System.String]::Empty)
        New-Variable -Force -Option:'Private' -Name:'ArrayLength' -Value:([System.Int32]::Empty)
        New-Variable -Force -Name:'StringBuilder' -Value:([System.Text.StringBuilder]$Null)

        Write-Debug -Message:'Exiting Block: Begin'
    }

    process {
        Write-Debug -Message:'Entering Block: Process'

        Clear-Variable -Force -ErrorAction:'SilentlyContinue' -Name:(
            [System.Array](
                'Result'
            )
        )

        $ArrayLength = [System.Int32](
            ($Value | Measure-Object -Property:'Length' -Sum).Sum +
            ([System.Math]::Max($Value.Count, 1) * 2)
        )

        $StringBuilder = New-Object -TypeName:'System.Text.StringBuilder' -ArgumentList:(
            $ArrayLength, $ArrayLength
        )

        0..([System.Math]::Max($Value.Count - 1, 0)) | & {
            process {
                $Null = $StringBuilder.Append([System.String]('{0}, ' -f $Value[$PSItem]))
            }
            end {
                $Null = $StringBuilder.Remove(($StringBuilder.Length - 2), 2)
            }
        }

        $Result = [System.String](
            $StringBuilder.ToString()
        )

        $Result
        Write-Debug -Message:'Exiting Block: Process'
    }

    end {
        Write-Debug -Message:'Entering Block: End'

        Remove-Variable -Force -ErrorAction:'SilentlyContinue' -Name:(
            @(
                'Result'
            )
        )

        Write-Debug -Message:'Exiting Block: End'
    }
}
