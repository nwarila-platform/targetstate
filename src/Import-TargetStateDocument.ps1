<#
Design:
- Phase 6 fresh TargetState document loader; not recovered source.
- Parses JSON TargetDocument input with Windows PowerShell 5.1 built-in ConvertFrom-Json.
- Rejects malformed or unknown document/resource shapes through ThrowError.
#>
function Import-TargetStateDocument {
    [CmdletBinding(
        ConfirmImpact = 'None',
        DefaultParameterSetName = 'Path',
        PositionalBinding = $true
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Path',
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Path,

        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Json',
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Json
    )

    begin {
        function Test-TargetStateProperty {
            param(
                [Parameter(Mandatory = $true)]
                [AllowNull()]
                [System.Object]
                $InputObject,

                [Parameter(Mandatory = $true)]
                [System.String]
                $Name
            )

            ($null -ne $InputObject) -and ($InputObject.PSObject.Properties.Name -contains $Name)
        }

        function Invoke-TargetStateDocumentError {
            param(
                [Parameter(Mandatory = $true)]
                [System.String]
                $Message,

                [Parameter(Mandatory = $true)]
                [System.String]
                $ErrorId,

                [Parameter(Mandatory = $false)]
                [AllowNull()]
                [System.Object]
                $TargetObject
            )

            ThrowError -ExceptionName 'System.ArgumentException' -ExceptionMessage $Message -ExceptionObject $TargetObject -ErrorId $ErrorId -ErrorCategory 'InvalidArgument'
        }
    }

    process {
        if ($PSCmdlet.ParameterSetName -eq 'Path') {
            try {
                $JsonText = Get-Content -LiteralPath $Path -Raw -ErrorAction Stop
            }
            catch {
                Invoke-TargetStateDocumentError -Message ('Unable to read TargetState document: {0}' -f $Path) -ErrorId 'TargetStateDocumentReadFailed' -TargetObject $Path
            }
        }
        else {
            $JsonText = $Json
        }

        try {
            $Document = $JsonText | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            Invoke-TargetStateDocumentError -Message 'TargetState document is not valid JSON.' -ErrorId 'TargetStateDocumentInvalidJson' -TargetObject $JsonText
        }

        foreach ($RequiredProperty in @('apiVersion', 'kind', 'metadata', 'resources')) {
            if (-not (Test-TargetStateProperty -InputObject $Document -Name $RequiredProperty)) {
                Invoke-TargetStateDocumentError -Message ('TargetState document is missing {0}.' -f $RequiredProperty) -ErrorId 'TargetStateDocumentMissingProperty' -TargetObject $Document
            }
        }

        if ([System.String]$Document.apiVersion -ne 'targetstate.nwarila.dev/v1alpha1') {
            Invoke-TargetStateDocumentError -Message ('Unsupported apiVersion: {0}' -f $Document.apiVersion) -ErrorId 'TargetStateDocumentUnsupportedApiVersion' -TargetObject $Document
        }

        if ([System.String]$Document.kind -ne 'TargetDocument') {
            Invoke-TargetStateDocumentError -Message ('Unsupported kind: {0}' -f $Document.kind) -ErrorId 'TargetStateDocumentUnsupportedKind' -TargetObject $Document
        }

        if (-not (Test-TargetStateProperty -InputObject $Document.metadata -Name 'name')) {
            Invoke-TargetStateDocumentError -Message 'TargetState document is missing metadata.name.' -ErrorId 'TargetStateDocumentMissingName' -TargetObject $Document
        }

        $Resources = [System.Object[]]@($Document.resources)
        if ($Resources.Count -lt 1) {
            Invoke-TargetStateDocumentError -Message 'TargetState document must include at least one resource.' -ErrorId 'TargetStateDocumentEmptyResources' -TargetObject $Document
        }

        $RegistryResources = foreach ($Resource in $Resources) {
            ConvertTo-TargetStateRegistryResource -Resource $Resource
        }

        [pscustomobject][ordered]@{
            ApiVersion = [System.String]$Document.apiVersion
            Kind = [System.String]$Document.kind
            Metadata = [pscustomobject][ordered]@{
                Name = [System.String]$Document.metadata.name
            }
            Resources = [System.Object[]]@($RegistryResources)
        }
    }
}
