Function Get-TargetResource {
  [CmdletBinding(
     ,  ConfirmImpact            =  'None'
     ,  DefaultParameterSetName =  'Default'
     ,  PositionalBinding        = $True
  )]
  Param(
    [Parameter(
       , Mandatory          = $True
       ,,  ParameterSetName  =  'Default'
       ,,  Position           = 0
       , ValueFromPipeline = $True
    )]
    [PSCustomObject]
    $InputObject
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'Result'               -Value:([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'IsFriendlyRegHive'    -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'IsValidRegHive'       -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryKeyExists'    -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryValueExists'  -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'KeyValueProvided'     -Value:([System.Int32]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryHive'         -
Value: ([Microsoft.Win32.RegistryKey]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryKey'          =
Value: ([Microsoft.Win32.RegistryKey]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(
      [System.Array](
         'Result',  'RegistryHive',  'RegistryKey',  'IsFriendlyRegHive',  'IsValidRegHive'
      )
    )
    # Create a RegistryKey object open to target registry hive.
    Set-Variable -Name: 'RegistryHive'  -Value:(
      [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::"$($InputObject.RegistryKeyHive.ShortName)",
        [Microsoft.Win32.RegistryView]::Default
      )

)
# Create a RegistryKey object open to target registry key with minimal permissions.
Set-Variable -Name: 'RegistryKey'  -Value:(
  $RegistryHive. OpenSubKey(
    ('{0}\{1}'  -f $InputObject.RegistryKeyPath,  $InputObject.RegistryKeyName),
    [Microsoft.Win32.RegistryKeyPermissionCheck]::Default,
    [System.Security.AccessControl.RegistryRights]::QueryValues
  )
)
# Check to
Set-Variable -Name:'RegistryKeyExists'  -Value:([System.Boolean] (
    ($Null -eq $RegistryKey) -eq $False
))
# RegistryKey will be equal to null if the key does not exist.
If ($RegistryKeyExists -eq $True) {
  # Check each property if they are Null or Empty,  then convert the boolean to a int, which
  #   results in  'False = 0'  and  'True = 1',  then multiply that by bit values so we can
  #   accurately predict the value combination using basic INT value checks.
  Set-Variable -Name:'KeyValueProvided'  -Value:([System.Int32](
    ([System.Int32]( [System.String]::IsNullOrEmpty($InputObject.RegistryValueName) -eq $False) * 1) +
    ([System.Int32]([System.String]::IsNullOrEmpty($InputObject.RegistryValueKind) -eq $False) * 2)
  ))
  Switch ($KeyValueProvided) {
    # If $PSItem = 0,  then both key values are empty.
    { $PSItem -eq 0 } {
      # We do not need to check the key value.
      Write-Debug -Message: (
         "KeyValue, ValueName,  and ValueData all empty,  only reporting registry key status.'
      )
    }
    # RegistryValueType HAS been provided,  RegistryValueData might have been provided. This
    #   means the user is likely targetting the  'default'  key,  but we need to confirm
    #   RegistryValueType is configured as  'REG_SZ'  to confirm.
    { $PSItem -eq 2  } {
      Set-Variable -Name: 'RegistryValueKindIsString'  -Value:([System.Boolean] (
        $InputObject.RegistryValueKind -eq  [Microsoft.Win32.RegistryValueKind]::String
      ))
      # If value kind is  'string', we are can be reasonably confident the user meant to target
      #   the  'default'  key.
      If ($RegistryValueKindIsString -eq $True) {
        Set-Variable -Name: 'RegistryValueData'  -Value: (
          $RegistryKey.GetValue('')
        )
      }
    } #end:  {$ PSItem -eq 2 }
    # All 3 required variables were provided,  so now we just query the values we need.
    { $PSItem -eq 3 } {
      # Test to see if the Registry Key Value exists.
      Set-Variable -Name: 'RegistryValueExists'  -Value:([System.Boolean] (
        $RegistryKey.GetValueNames() -contains $InputObject.RegistryValueName
      ))
      # If the registry value exists, we then need to query the values of RegistryValueType and
      #   RegistryValueData
      If ( $RegistryValueExists -eq $True ) {
        Set-Variable -Name: 'RegistryValueData'  -Value:(
          $RegistryKey.GetValue(
            $InputObject.RegistryValueName,
            $null,
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames

               )
             )
            Set-Variable -Name:'RegistryValueKind'  -Value: (
               [Microsoft.Win32.RegistryValueKind](
                 $RegistryKey.GetValueKind($InputObject.RegistryValueName )
               )
             )
          }
        } #end:  { $PSItem -eq 3 }
        default {
          # If we reach here, we changed the  'KeyValueProvided'  variable in some meaningful way.
        }
      } #end:  Switch ($KeyValueProvided)
    } #end:  If ($RegistryKeyExists -eq $True)
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name:'Result'  -Value:([Hashtable]a{
      KeyExists   = $RegistryKeyExists
      ValueExists = $RegistryValueExists
      ValueData   = $RegistryValueData
      ValueKind   = $RegistryValueKind
    })
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message: 'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'Result'
    ))
    Write-Debug -Message: 'Exiting Block:  End'
  }
