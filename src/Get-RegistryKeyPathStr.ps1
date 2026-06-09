Function Get-RegistryKeyPathStr {
  [CmdletBinding(
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
    , ConfirmImpact            =  'None'
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [ValidateNotNull()]
    [System.String]
    $KeyPath
  )
  Begin {
      Write-Debug -Message:'Entering Block:  Begin'
      # Initalize DYNAMIC Variables
      New-Variable -Force -Option:'Private'  -Name:'Result'                   -Value:([System.String]::Empty)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasNonPrintChars'  -Value:($False)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasDoubleSlashes'  -Value:($False)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasLeadingSlash'   -Value:($False)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasTrailingSlash'  -Value:($False)
      Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
      Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #   values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(@(
      'Result',  'KeyPathHasNonPrintChars',  'KeyPathHasDoubleSlashes',
      'KeyPathHasLeadingSlash',  'KeyPathHasTrailingSlash'
     ))
    # Key names cannot any non-printable characters.

  Set-Variable -Name:'KeyPathHasNonPrintChars'  -Value:([System.Boolean](
    $KeyPath -match  '[\p{Cc}\p{Cn}\p{Cs}]'
  ))
  If ($KeyPathHasNonPrintChars -eq $True) {
    ThrowError `
      -ErrorId: 'InvalidRegistryKeyName ' `
      -ErrorCategory: 'InvalidArgument' `
      -ExceptionName: 'System.ArgumentException' `
      -ExceptionObject:$KeyPath `
      -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
  }
  Set-Variable -Name: 'NormalizedKeypath'  -Value:([System.String](
    $KeyPath
  ))
  Set-Variable -Name:'KeyPathHasDoubleSlashes'  -Value:([System.Boolean] (
    $NormalizedKeypath -match ('\\{2,}')
  ))
  If ($KeyPathHasDoubleSlashes -eq $True) {
    Set-Variable -Name: 'NormalizedKeypath'  -Value:([System.String](
      $NormalizedKeypath -replace ('\\+',  '\')
    ))
  }
  Set-Variable -Name:'KeyPathHasLeadingSlash'  -Value:([System.Boolean] (
    $NormalizedKeypath[0] -eq  '\'
  ))
  If ($KeyPathHasLeadingSlash -eq $True) {
    Set-Variable -Name:'NormalizedKeypath'  -Value:([System.String](
      $NormalizedKeypath.Substring(1)
    ))
  }
  Set-Variable -Name:'KeyPathHasTrailingSlash'  -Value:([System.Boolean](
    $NormalizedKeypath[-1]  -eq  '\'
  ))
  If ($KeyPathHasTrailingSlash -eq $True) {
    Set-Variable -Name: 'NormalizedKeypath'  -Value:([System.String](
      $NormalizedKeypath.TrimEnd('\' )
    ))
  }
  # It's always desirable to explicitly set the Result object with its desired class as close
  #   to the soft return to ensure the output is predictable and easily traceable.
  Set-Variable -Name:'Result'  -Value:([System.String] (
    $NormalizedKeypath
  ))
  # Do a  'soft'  return by outputting the result to the pipe without using the return function
  #   which would immediately end the function,  this enables us to have the very last
  #   executing item be write-debug giving us a valuable breakpoint & enabling better
  #   debugging functionality and output.
  $Result
  Write-Debug -Message:'Exiting Block:  Process'
} End {
  Write-Debug -Message:'Entering Block:  End'
  # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't
  #   technically required as they will automatically be disposed of when leaving a function,
  #   but I consider this best practice as it forces me to be mindful of all used variables.
  Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:([System.Array](
    'Result',  'KeyPathHasNonPrintChars',  'KeyPathHasDoubleSlashes',
    'KeyPathHasLeadingSlash',  'KeyPathHasTrailingSlash',  'KeyName'
  ))
  Write-Debug -Message:'Exiting Block:  End'
}

}
