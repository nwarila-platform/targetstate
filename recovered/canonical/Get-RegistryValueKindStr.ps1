Function Get-RegistryValueKindStr {
  [CmdletBinding(
    DefaultParameterSetName =  'Default'
    ,  PositionalBinding     = $True
    ,  ConfirmImpact          =  'None'
  )]
  Param(
    [Parameter(
      ParameterSetName  =  'Default',
      Position           = 0,
      Mandatory          = $True,
      ValueFromPipeline = $True
    )]
    [AllowEmptyString()]
    [ValidateNotNull()]
    [System.String]
    $ValueKind
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'IsValidValueKind'        -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'NormalizedValueKind'     -
Value:([Microsoft.Win32.RegistryValueKind]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'ValueKindIsUnknown'      -
Value:([Microsoft.Win32.RegistryValueKind]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'Result'                  -
Value:([Microsoft.Win32.RegistryValueKind]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
       'ValueKindIsNullorEmpty',  'IsValidValueKind',  'NormalizedValueKind',
       'ValueKindIsUnknown',  'Result'
    ))
    Set-Variable -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean] (
      [System.String]::IsNullOrWhiteSpace($ValueKind)
    ))
    If ($ValueKindIsNullorEmpty -eq $True) {

      Set-Variable -Name: 'NormalizedValueKind'  -Value:(
        [Microsoft.Win32.RegistryValueKind]::None
      )
    } Else {
      # Validate the Registry Hive value against a list of valid and support registry hives.
      Set-Variable -Name:'IsValidValueKind'  -Value: (
        [System.Boolean] (
          [Enum]::TryParse(
             [Microsoft.Win32.RegistryValueKind],
            $ValueKind,
            [Ref ]$NormalizedValueKind
          )
        )
      )
      # While  'Unknown'  is a valid RegistryValueKind,  it's not a relevant value for our function
      #   so we treat it as Invalid and raise an exception.
      Set-Variable -Name:'ValueKindIsUnknown'  -Value:(
        [System.Boolean] (
          $NormalizedValueKind -eq  'Unknown'
        )
      )
      # If the Registry Key Value Type is invalid,  raise am error and exit the function.
      If (($IsValidValueKind -eq $False) -or ($ValueKindIsUnknown -eq $True)) {
        ThrowError `
          -ErrorId: 'InvalidRegistryValueTypeSpecified' `
          -ErrorCategory: 'InvalidArgument' `
          -ExceptionName: 'System.ArgumentException' `
          -ExceptionObject:$ValueKind `
          -ExceptionMessage: $LocalizedData.InvalidRegistryValueTypeSpecified
      }
    } #else
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name: 'Result'  -Value:(
      [Microsoft.Win32.RegistryValueKind](
        $NormalizedValueKind
      )
    )
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  listed) and cleaned up.  This isn't
    # =  technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
      'ValueKindIsNullorEmpty',  'IsValidValueKind',  'ValueKind',
      'ValueKindIsUnknown',  'Result',  'NormalizedValueKind'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
} #Function Get-RegistryValueKindStr
