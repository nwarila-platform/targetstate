<#
Provenance:
- Source PDF: 06042026_001.pdf
- Rendered page images: _recovery/06042026_001/images/page-0001.png through page-0002.png
- Phase 2 decision: keep_B
- Recovery scope: Phase 3 pure function stabilization

OCR corrections:
- Corrected OCR variable sigils in `$ExceptionMessage` and `$ErrorCategory`.
- Corrected smart quote / comma drift in parameter attributes.
- Corrected namespace spacing for `System.Management.Automation.ErrorRecord`.
#>
function ThrowError {
    [CmdletBinding(
        ConfirmImpact = 'Low',
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
        $ExceptionName,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 1
        )]
        [ValidateNotNull()]
        [System.String]
        $ExceptionMessage,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 2
        )]
        [ValidateNotNull()]
        [System.Object]
        $ExceptionObject,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 3
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ErrorId,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Default',
            Position = 4
        )]
        [ValidateNotNull()]
        [System.Management.Automation.ErrorCategory]
        $ErrorCategory
    )

    process {
        $exception = New-Object $ExceptionName $ExceptionMessage
        $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception, $ErrorId, $ErrorCategory, $ExceptionObject
        throw $errorRecord
    }
}
