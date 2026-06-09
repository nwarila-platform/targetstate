Function Get-RegistryKeyNameStr {
  [CmdletBinding(
    ,  ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $KeyName
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'Result'                   -Value:( [System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'KeyNameHasBackslash'      -Value:($False)
    New-Variable -Force -Option:'Private'  -Name:'KeyNameHasNonPrintChars'  -Value:($False)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'Result',  'KeyNameHasBackslash',  'KeyNameHasNonPrintChars'
    ))
    # Key names cannot include the backslash ('\') character.
    Set-Variable -Name: 'KeyNameHasBackslash'  -Value:([System.Boolean] (
      $KeyName.Contains('\')
    ))
    If ($KeyNameHasBackslash -eq $True) {
      ThrowError `
        -ErrorId: 'InvalidRegistryKeyName' `
        -ErrorCategory: 'InvalidArgument' `
        -ExceptionName: 'System.ArgumentException' `
        -ExceptionObject: $KeyName `
        -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
    }
    # Key names cannot any non-printable characters.
    Set-Variable -Name:'KeyNameHasNonPrintChars'  -Value:([System.Boolean] (
      $KeyName -match  '[\p{Cc}\p{Cn}\p{Cs}]'
    ))
    If ($KeyNameHasNonPrintChars -eq $True) {
      ThrowError `
        -ErrorId: 'InvalidRegistryKeyName' `
        -ErrorCategory: 'InvalidArgument' `
        -ExceptionName: 'System.ArgumentException' `
        -ExceptionObject: $KeyName `
        -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
    }
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name:'Result'  -Value:( [System.String] (
      $KeyName
    ))
    # Do a  'soft'  return by outputting the result to the pipe without using the return function

    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  listed) and cleaned up. This isn't
    # =  technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
      'KeyName',  'Result',  'KeyNameHasBackslash',  'KeyNameHasNonPrintChars'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
