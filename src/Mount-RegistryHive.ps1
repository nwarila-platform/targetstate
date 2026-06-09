Function Mount-RegistryHive {
  [CmdletBinding(
       ConfirmImpact            =  'Low'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True

    ,  SupportsShouldProcess   = $True
  )]
Param(
  [Parameter(
    Mandatory          = $True
    ,  ParameterSetName  =  'Default'
    ,  Position           = 0
    , ValueFromPipeline = $True
  )]
  [ValidateNotNullOrEmpty( )]
  [Hashtable]
  $RegistryHive
)
Begin {
  Write-Debug -Message:'Entering Block: Begin'
  # Initalize Variables
  New-Variable -Name: 'Result'               -Force -Option:('Private') -Value:( $Null  )
  New-Variable -Name:'RegistryKeyStr'       -Force -Option:('Private') -Value:(  [System.String]::Empty   )
  New-Variable -Name:'ShouldMountRegistry'  -Force -Option:('Private') -Value:(  $False )
  New-Variable -Name: 'RegistryIsMounted'    -Force -Option:('Private') -Value:(  $False )
  Write-Debug -Message:'Exiting Block:  Begin'
} Process {
  Write-Debug -Message:'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:@(
    'Result',  'ShouldMountRegistry',  'RegistryIsMounted'
  )
  # Test to see if the Registry Hive is mounted.
  Set-Variable -Name: 'ShouldMountRegistry'  -Value:(
    [System.Boolean] (
      (Test-Path -Path:('Registry::{0}'  -f $RegistryHive.Abbreviation)) -eq $False
    )
  )
  If ($ShouldMountRegistry) {
    If ($PSCmdlet.ShouldProcess($RegistryHive.Name,  'Mount registry hive')) {
      Try {
        # ----------------------------------
        New-PSDrive `
          -Name:($RegistryHive.Abbreviation) `
          -PSProvider:('Registry') `
          -Scope:('Script') `
          -Root: ($RegistryHive.Name)
      } Catch {
        Throw $_
      }
    }
  }
  # Recheck the value attempting to mount PSDrive
  Set-Variable -Name:'RegistryIsMounted'  -Value:([System.Boolean] (
    Test-Path -Path:('Registry::{0}'  -f $RegistryHive.Abbreviation)
  ))
  # If registry is not correctly mounted,  then we need to throw an error.
  If ($RegistryIsMounted -eq $False) {
      ThrowError                                  `
          -ErrorId: 'RegistryHiveMountFailed' `
          -ErrorCategory: 'InvalidOperation' `
          -ExceptionName: 'System.IO.IOException' `
          -ExceptionObject:$RegistryHive `
          -ExceptionMessage: 'Unable to mount registry'
  }
  # It's always desirable to explicitly set the Result object with its desired class as close
  #   to the soft return to ensure the output is predictable and easily traceable.
  Set-Variable -Name:'Result'  -Value:($Null)

    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e. Listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
             'Result',  'RegistryKeyStr',  'ShouldMountRegistry',  'RegistryIsMounted'
         ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
