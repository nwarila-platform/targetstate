Function ThrowError {
  [CmdletBinding(
       DefaultParameterSetName =  'Default'
    # , SupportsShouldProcess = $True
    ,  PositionalBinding = $True
    , ConfirmImpact =  'Low'
  )] Param(
    [Parameter(
        Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $ExceptionName,
    [Parameter(
        Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           =1

      , ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $ExceptionMessage,
    [Parameter (
        Mandatory         = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 2
      , ValueFromPipeline = $true
    )]
    [System.Object]
    $ExceptionObject,
    [Parameter(
        Mandatory         = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 3
      , ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty( )]
    [System.String]
    $ErrorId,
    [Parameter(
        Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 4
      , ValueFromPipeline = $true
    )]
    [ValidateNotNull()]
    [System.Management.Automation.ErrorCategory]
    $ErrorCategory
  )
  $exception = New-Object $ExceptionName $ExceptionMessage;
  $errorRecord = New-Object System.Management.Automation.ErrorRecord $exception,  $ErrorId,  $ErrorCategory,
$ExceptionObject
  throw $errorRecord
}
