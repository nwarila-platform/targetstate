Function Get-RegistryKeyHive {
    [CmdletBinding(
        DefaultParameterSetName =  'Default'
        ,ConfirmImpact =  'None'
        ,  PositionalBinding = $True
    )]
    Param(
        (Parameter( ParameterSetName =  'Default',  Position = 1, Mandatory = $True, ValueFromPipeline =
$True )]
        [ValidateNotNullOrEmpty( )]
        [System.String]
        $RegistryKey
    )
    Begin {
        Write-Debug -Message: 'Entering Block:  Begin'
        # Initalize STATIC Variables
        New-Variable -Name: 'REGISTRY_HIVE_EXCEPTION_HASH'  -Force -Option:('Private',  'ReadOnly') -Value:a{
            ExceptionName    =  'System.ArgumentException'
            ExceptionObject  = $RegistryKey
            ErrorId           =  'InvalidRegistryHive'
            ErrorCategory    =  'InvalidArgument '
            ExceptionMessage = $LocalizedData.InvalidRegistryHiveSpecified -f $RegistryKey
        }
        # Initalize Variables
        New-Variable -Name: 'Result'        -Force -Option:'Private'  -Value:(  [System.String]$Null    )
        New-Variable -Name: 'RegistryHive'  -Force -Option: 'Private'  -Value:(  [System.String]$Null    )}
        New-Variable -Name: 'HasBackslash'  -Force -Option: 'Private'  -Value:(  [System.Boolean]$Nulll  )
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message: 'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:@(
            'Result', 'RegistryHive', 'HasBackslash'

        )
        # Copy the value of RegistryKey to a new object and normalize it so that we can manipulate as we want
        #     without obscutating the origional value,  a value that may be useful during debuging efforts.
        Set-Variable -Name:'RegistryHive'  -Value:([System.String](
            $RegistryKey
        ))
        # Test if the RegistryKey string has a backslash,  so we can split if needed.
        Set-Variable -Name:'HasBackslash'  -Value:([System.Boolean] (
            $RegistryHive.Contains('\') -eq $True
        ))
        # Pre-Evaluate the conditional expression(s) now for easy debugging & cleaner code.
        If ($HasBackslash) {
            # Set the value of RegistryHive to all characters before first backslash ('\').
            Set-Variable -Name: 'RegistryHive'  -Value:([System.String]}(
                $RegistryHive.Split('\') [0]
            ))
        }
        # Cleanup all conditional variables as soon as they are no longer needed.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@('HasBackslash' ))
        # Attempt to match the registry hive,  then returns an expected and normalized value.
        Switch -Regex ($RegistryHive) {
            '*(hkey_classes_root|hkcr)$'     { Set-Variable -Name:''Result'  -Value:('HKEY_CLASSES_ROOT')   }
            '"(hkey_current_user|hkcu)$'    { Set-Variable -Name:'Result'  -Value:('HKEY_CURRENT_USER')    }
            'A4(hkey_local_machine|hklm)$'   { Set-Variable -Name:'Result'  -Value:('HKEY_LOCAL_MACHINE')  }
            '"(hkey_users|hkus)$'           { Set-Variable -Name:'Result'  -Value:('HKEY_USERS')           }
            '"(hkey_current_config|hkcc)$'  { Set-Variable -Name:'Result'  -Value:('HKEY_CURRENT_CONFIG') }
            Default { ThrowError @REGISTRY_HIVE_EXCEPTION_HASH }
        }
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        ([System.String]$Result)
        Write-Debug -Message: 'Exiting Block:  Process'
    } End {
        Write-Debug -Message:'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. Listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
            'RegistryKey','Result', 'RegistryHive','HasBackslash'
        ))
        Write-Debug -Message:'Exiting Block:  End'
    }
}
