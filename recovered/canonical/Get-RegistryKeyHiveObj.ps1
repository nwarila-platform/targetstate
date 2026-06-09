Function Get-RegistryKeyHiveObj {
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
  $KeyHive
)
Begin {
  Write-Debug -Message:'Entering Block:  Begin'
  # Initalize DYNAMIC Variables
  New-Variable -Force -Option:'Private'  -Name:'Result'        -Value:([System.String]::Empty)
  New-Variable -Force -Option:'Private'  -Name:'RegistryHive'  -Value:([Hashtable]::Empty)
  Write-Debug -Message:'Exiting Block:  Begin'
} Process {
  Write-Debug -Message:'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:([System.Array](
    'Result',  'RegistryHive'
  ))
  Switch ($KeyHive) {
    { $PSItem -in @(,  'HKCR',  'HKEY_CLASSES ROOT',  'ClassesRoot',  '-2147483648') } {
      Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_CLASSES_ROOT'
        ShortName    =  'ClassesRoot'
        Abbreviation =  'HKCR'
      })
    }
    { $PSItem -in @(,  'HKCU',  'HKEY_CURRENT_USER',  'CurrentUser',  '-2147483647') } {
      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_CURRENT_USER'
        ShortName    =  'CurrentUser'
        Abbreviation =  'HKCU'
      })
    }
    { $PSItem -in @(,  'HKLM',  'HKEY_LOCAL_MACHINE',  'LocalMachine',  '-2147483646') } {
      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_LOCAL_MACHINE'
        ShortName    =  'LocalMachine'
        Abbreviation =  'HKLM'
      })
    }
    { $PSItem -in @(,  'HKU',  'HKEY_USERS',  'Users',  '-2147483645')  } {
      Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_USERS'
        ShortName    =  'Users'
        Abbreviation =  'HKU'
      })
    }
    { $PSItem -in @(,  'HKPD',  'HKEY_PERFORMANCE_DATA',  'PerformanceData',  '-2147483644') } {
      Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_PERFORMANCE_DATA'
        ShortName    =  'PerformanceData'
        Abbreviation =  'HKPD'
      })
    }
    { $PSItem -in @(,  'HKCC',  'HKEY_CURRENT_CONFIG',  'CurrentConfig',  '-2147483643') } {
      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]a{
        Name          =  'HKEY_CURRENT_CONFIG'
        ShortName    =  'CurrentConfig'
        Abbreviation =  'HKCC'
      })
    }
    default {
      ThrowError `
        -ErrorId: 'InvalidRegistryHiveSpecified' `
        -ErrorCategory: 'InvalidArgument ' `

          -ExceptionName: 'System.ArgumentException' `
          -ExceptionObject:$KeyHive `
          -ExceptionMessage: $LocalizedData. InvalidRegistryHiveSpecified
      }
    }
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name:'Result'  -Value:([Hashtable](
      $RegistryHive
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
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
            'KeyHive',  'Result',  'RegistryHive'
        ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
