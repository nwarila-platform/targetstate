Function Get-RegistryValueData {
  [CmdletBinding(
    , ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding        = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [ValidateSet(
      ,  'String'
      ,  'ExpandString'
      ,  'MultiString'
      ,  'DWord'
      ,  'QWord'
      ,  'Binary'
    )]
    [System.String]
    $Type,
    [Parameter(
      , Mandatory          = $False

    ,  ParameterSetName  =  'Default'
    ,  Position           = 1
    , ValueFromPipeline = $True
  )]
  [ValidateNotNull()]
  [System.String[]]
  $Data,
  [Parameter(
    , Mandatory          = $False
    ,  ParameterSetName  =  'Default'
    ,  Position           = 2
    , ValueFromPipeline = $True
  )]
  [System.Boolean]
  $Hex,
  [Parameter(
    , Mandatory          = $True
    ,  ParameterSetName  =  'Default'
    ,  Position           = 3
    , ValueFromPipeline = $True
  )]
  [System.Management.Automation.PSReference]
  $Result
)
Begin {
  Write-Debug -Message: 'Entering Block:  Begin'
  # Initalize DYNAMIC Variables
  New-Variable -Force -Option:'Private'  -Name:'Result'        -Value:([System.String]::Empty)
  New-Variable -Force -Option:'Private'  -Name: 'ErrorMessage'  -Value:([System.String]::Empty)
  Write-Debug -Message: 'Exiting Block:  Begin'
} Process {
  Write-Debug -Message:'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(
    [System.Array](
      'Result',  'RegistryHive',  'RegistryKey',  'IsFriendlyRegHive',  'IsValidRegHive'
    )
  )
  Set-Variable -Name: 'DataString'         -Value:(ConvertFrom-Array -Value:$Data)
  Set-Variable -Name:'IsDataMultiple'     -Value:([System.Boolean]($Data.Count -gt 1))
  Set-Variable -Name:'IsDataMultiString'  -Value:([System.Boolean]($Type -ine  'MultiString' ))
  Set-Variable -Name:'IsDataNullOrEmpty'  -Value:([System.Boolean](
    [System.String]::IsNullOrEmpty($Data)
  ))
  #
  If ($IsDataMultiString -and $IsDataMultiple -and $IsDataNull) {
    # Load the Appropriate Error Message
    Set-Variable -Name:'ErrorMessage'  -Value:([System.String](
      $localizedData.ParameterValueInvalid -f (
        'ValueData',
        $DataString,
        $Type
      )
    ))
    ThrowError `
      -ErrorCategory: 'InvalidArgument ' `
      -ErrorId: "ArrayNotExpectedForType$($Type)" `
      -ExceptionMessage: $ErrorMessage `
      -ExceptionName: 'System.ArgumentException' `
      -ExceptionObject:$Data
  }

    Switch ($Type) {
      ($PSItem -in @('String',  'ExpandString')) {
        If ($IsDataNullOrEmpty -eq $True) {
          Set-Variable -Name:'Result'  -Value:([System.String]::Empty)
        } Else {
          Set-Variable -Name:'Result'  -Value:([System.String]($Data[0]))
        }
      }
      'MultiString'  {
        If ($IsDataNullOrEmpty -eq $True) {
          Set-Variable -Name:'Result'  -Value:([System.String[]]::new(0))
        } Else {
          Set-Variable -Name:'Result'  -Value:([System.String[]]($Data) )
        }
      }
      'DWord'  {
        If ($IsDataNullOrEmpty -eq $True) {
          Set-Variable -Name:'Result'  -Value:([System.Int32]0)
        } ElseIf($Hex -eq $True) {
          $DataStr
        } Else {
        }
      }
      'QWord'  {
      }
      'Binary'  {
      }
    }
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    # Set-Variable -Name:'Result'  -Value:($null)
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message: 'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e. Listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'Result'
    ))
    Write-Debug -Message: 'Exiting Block:  End'
  }
}
