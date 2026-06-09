<#
    Exported Commands Execution Logic
    Get-TargetResourceInternal
        -> Start-Provider
            ~> Get-RegistryKeyString
                -> Get-NormalizedRegistryKeyString
                -> Get-RegistryHive
                     -> Get-NormalizedRegistryKeyString
                -> Get-RegistryKeyPath
                     -> Get-NormalizedRegistryKeyString
                ~> Get-RegistryKeyName
                     -> Get-NormalizedRegistryKeyString
            -> Mount-RegistryHive
#>
data localizedData {
  # culture = "en-US"
  ConvertFrom-StringData @'
    ParameterRequired = (ERROR) Mandatory parameter  '{0}'  is missing.
    ParameterValueInvalid = (ERROR) Parameter  '{0}'  has an invalid value  '{1}'  for type  '{2}'
    InvalidPSDriveSpecified = (ERROR) Invalid PSDrive  '{0}'  specified in registry key  '{1}'
    InvalidRegistryHiveSpecified = (ERROR) Invalid registry hive was specified in registry key  '{0}'
    InvalidRegistryValueTypeSpecified = (ERROR) Invalid registry key value type was specified in registry key
    InvalidRegistryKeyNameSpecified = (ERROR) Invalid registry key was specified in registry key  '{0}'
    SetRegValueFailed = (ERROR) Failed to set registry key value  '{0}' to value  '{1}'  of type  '{2}'
    SetRegValueUnchanged = (UNCHANGED) No change to registry key value  '{0}'  containing '{1}'
    SetRegKeyUnchanged = (UNCHANGED) No change to registry key  '{0}'
    SetRegValueSucceeded = (SET) Set registry key value  '{0}'  to  '{1}'  of type  '{2}'
    SetRegkeySucceeded = (SET) Create registry key  '{0}'
    SetRegkeyFailed = (ERROR) Failed to created registry key  '{0}'
    RemoveRegKeyTreeFailed = (ERROR) Registry Key  '{0}'  has subkeys,  cannot remove without Force flag
    RemoveRegkeySucceeded = (REMOVAL) Registry key  '{0}'  removed
    RemoveRegKeyFailed = (ERROR) Failed to remove registry key  '{0}'
    RemoveRegValueSucceeded = (REMOVAL) Registry key value  '{0}'  removed
    RemoveRegValueFailed = (ERROR) Failed to remove registry key value '{0}'
    RegKeyDoesNotExist = Registry key  '{0}' does not exist
    RegkeyExists = Registry key '{0}'  exists
    RegValueExists = Found registry key value  '{0}' with type  '{1}'  and data  '{2}'
    RegValueDoesNotExist = Registry key value  '{0}'  does not exist
    RegValueTypeMismatch = Registry key value  '{0}'  of type  '{1}'  does not exist
    RegValueDataMismatch = Registry key value  '{0}'  of type  '{1}'  does not contain data  '{2}'
    DefaultValueDisplayName = (Default)
'@
}
Function ThrowError {
  [CmdletBinding(
    ,  DefaultParameterSetName =  'Default'
    # , SupportsShouldProcess = $True
    ;  PositionalBinding = $True
    , ConfirmImpact =  'Low'
  )] Param(
    [Parameter(
      ; Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $ExceptionName,
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           =1

      , ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $ExceptionMessage,
    [Parameter (
      , Mandatory         = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 2
      , ValueFromPipeline = $true
    )]
    [System.Object]
    $ExceptionObject,
    [Parameter(
      , Mandatory         = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 3
      , ValueFromPipeline = $true
    )]
    [ValidateNotNullOrEmpty( )]
    [System.String]
    $ErrorId,
    [Parameter(
      , Mandatory          = $True
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
Function Start-ProviderSetup {
    [CmdletBinding(
        DefaultParameterSetName =  'Default'
        , SupportsShouldProcess = $True
        , ConfirmImpact          =  'Low'
        ,  PositionalBinding     = $True
    )] Param(
        [Parameter( ParameterSetName =  'Default',   Position = 0, Mandatory = $True, ValueFromPipeline =
$True )j
        [System.String]
        $RegistryKey,
        [Parameter( ParameterSetName =  'Default',   Position = 1, Mandatory = $True, ValueFromPipeline =
$True )]
        [System.String]
        $ValueName,
        [Parameter( ParameterSetName =  'Default',   Position = 2, Mandatory = $True, ValueFromPipeline =
$True )]
        [System.String]
        $ValueData,
        [Parameter( ParameterSetName =  'Default',   Position = 3, Mandatory = $True, ValueFromPipeline =
$True )]
        [System.String]
        $ValueType
    )
    Begin {
        Write-Debug -Message:'Entering Block:  Begin'

        # Initalize Variables
        New-Variable -Name: 'RegistryKeyStr'  -Force -Option:('Private') -Value:([PSCustomObject]$Null)
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message: 'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@('RegistryKeyStr' ))
        # Normalize the RegistryKey value so its value is predictable for the rest of the function.
        Set-Variable -Name: 'RegistryKeyString'  -Value:([System.String](
             Get-NormalizedRegistryKey -RegistryKey: ($RegistryKey)
        ))
        Set-Variable -Name: 'RegistryKeyHive'  -Value:( [System.String](
            Get-RegistryKeyHive -Value:($RegistrykeyString)
        ,)
        # Ensure that the Registry Hive is mounted and accessible.
        Mount-RegistryHive -RegistryKey: ($RegistryKeyStr)
        Set-Variable -Name:'RegistryKeyPath'  -Value:([System.String](
            Get-RegistryKeyPath -Value:($RegistryKeyString)
        ))
        Set-Variable -Name: 'RegistryKeyName'  -Value:([System.String](
            Get-RegistryKeyName -Value:($RegistryKeyString)
        ))
        If ($PSCmdlet.ParameterSetName -eq  'HasValue') {
            Set-Variable -Name:'RegistryKeyValue'  -Value:([System.String](
                $RegistryValue
            ))
            Set-Variable -Name:'RegistryKeyType'  -Value:( [System.String] (
                Get-RegistryKeyType -Value:$RegistryKeyType
            ))
        }
        g$Result.RegistryKey = $RegistryKeyStr
        # Build the final object we will be returning to the caller.
        Set-Variable -Name:'Result'  -Value:([PSCustomObject]@{
            RegistryKey       = [System.String]::Empty
            RegistryKeyHive   = [System.String]::Empty
            RegistryKeyPath   = [System.String]::Empty
            RegistryKeyName   = [System.String]::Empty
            RegistryValueName = [System.String]::Empty
            RegistryValueType = [System.String]::Empty
            RegistryValueData = [System.String]::Empty
        })
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        ([PSCustomObject]$Result)
        Write-Debug -Message:'Exiting Block:  Process'
    } End {
        Write-Debug -Message:'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@( 'RegistryKeyStr' })
        Write-Debug -Message: 'Exiting Block:  End'
    }
}

Function Get-NormalizedRegistryKey {
    <#
        This function is used to normalize the regsitry key string during the provider setup.  Its used to
ensure
            that all the RegistryKey value is in a valid and predictable format ensuring success of all
subsequent
            functions that will use that value.
    #>
    [CmdletBinding(
        DefaultParameterSetName =  'Default'
        , ConfirmImpact          =  'None'
        ,  PositionalBinding     = $True
    )]
    Param(                                                                                      ; `
        [Parameter( ParameterSetName =  'Default',  Position = 1, Mandatory = $True, ValueFromPipeline =
$True )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RegistryKey
    )
    Begin {
        Write-Debug -Message:'Entering Block:  Begin'
        # Initalize Variables
        New-Variable -Name: 'Result'            -Force -Option:('Private') -Value:([System.String]$Null)
        New-Variable -Name:'RegistryKeyStr'    -Force -Option:('Private') -Value:([System.String]$Null)
        New-Variable -Name:'HasDoubleSlashes'  -Force -Option:('Private') -Value:([System.Boolean]$Null)
        New-Variable -Name:'HasTrailingSlash'  -Force -Option:('Private') -Value:([System.Boolean]$Null)
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message:'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
             'RegistryKeyStr',  'HasDoubleSlashes',  'HasTrailingSlash',  ''Result'
        ))
        # Copy the value of RegistryKey to a new object that we can manipulate as we want without obscutating
the
        #     origional value of RegistryKey. This is to support debugging efforts and code execution
tracing.
        Set-Variable -Name: 'RegistryKeyStr'  -Value:([System.String](
            $RegistryKey
        ))
        # Test of string uses double backslashes in the key path.
        Set-Variable -Name: 'HasDoubleSLashes'  -Value:([System.Boolean](
            $RegistryKeyStr -contains ('\\')
        ))
        # If the string has any instances of double backslashes  '\',  replace all instances of two or more
        #     backslashes with a single backslash. This gives us the ability to reliably extract specific
        #     parts of the regsitry key path by splitting on backslashes.
        If ($HasDoubleSlashes) {
            # This check is done seperately so as this module matures, we can offer to raise a suggestion
about
            #     changing the registry key string format in the source file(s) to match the desired format.
            Set-Variable -Name:'RegistryKeyStr'  -Value:([System.String](
                $RegistryKeyStr -replace ('\\+','\')
             ))
        }
        # Test of string ends with a trailing backslash ('\').
        Set-Variable -Name: 'HasTrailingSlash'  -Value:([System.Boolean](
            $RegistryKeyStr.Endswith('\')
        ))
        # If the string ends with a trailing slash, we want to remove it as we want to ensure the registry
        #     key string is as predictable as possible. This gives us the ability to reliably extract
specific
        #     parts of the regsitry key path by splitting on backslashes.

        If ($HasTrailingSlash) {
            # This check is done seperately so as this module matures, we can offer to raise a suggestion
about
            #     changing the registry key string format in the source file(s) to match the desired format.
            Set-Variable -Name: 'RegistryKeyStr'  -Value:([System.String](
                 $RegistryKeyStr.TrimEnd('/')
             ))
        }
        # Explicitly set the Result Object before returning it so it can be easily and predictably analized
        #     during debug sessions. We explicitly type it here so if someone needs to quickly review the
        #     code they know exactly they type of return object WILL be returned.
        Set-Variable -Name:'Result'  -Value:([System.String](
            $RegistryKeyStr
         ))
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        [System.String]$Result
        Write-Debug -Message:'Exiting Block:  Process'
    } End {
        Write-Debug -Message:'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
             'RegistryKey', 'RegistryKeyStr','Result',  ''HasDoubleSlashes',  'HasTrailingSlash'
        ))
        Write-Debug -Message: 'Exiting Block:  End'
    }
}
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
Function Get-RegistryKeyPath {
    [CmdletBinding( DefaultParameterSetName =  'Default', ConfirmImpact =  'None',  PositionalBinding = $True)]
    Param(
;        {[Parameter( Position = 1,  ParameterSetName =  'Default', Mandatory = $True, ValueFromPipeline =
 True )]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $RegistryKey
    )
    Begin {
        Write-Debug -Message:'Entering Block:  Begin'
        # Initalize STATIC Variables
        New-Variable -Name: 'REGISTRY_KEYPATH_REGEX'  -Force -Option:('Private',  'ReadOnly') -Value:(
            '(?:^[^\\\r\n]+\\(?<RegistryKeyPath>.*)\\.+$)'
        )
        # Initalize Variables

        New-Variable -Name: 'Result'                -Force -Option: 'Private'  -Value:([System.String]$Null)
        New-Variable -Name: 'RegexMatchSuccess' -Force -Option:'Private'  -Value:([System.Boolean]$Null)
        New-Variable -Name: 'RegistryKeyPathRegex'  -Force -Option: 'Private'  -Value:(
             [System.Text.RegularExpressions.MatchCollection]$Null
         )
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message:'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
             'Result', 'RegistryKeyPathRegex', 'RegexMatchSuccess'
         ))
        # Using Regex,  try to extract the registry key path for reference later.
        Set-Variable -Name: 'RegistryKeyPathRegex'  -Value:([Regex]::Matches($RegistryKey,
$REGISTRY_KEYPATH_REGEX) )
        # Pre-Evaluate the conditional expression(s) now for easy debugging & cleaner code.
        Set-Variable -Name: 'RegexMatchSuccess'  -Value:($RegistryKeyPathRegex.Success -eq $True)
        # All Conditions Are Pre-Evaluated & Normalized So Its Expected To Be True
        If ($RegexMatchSuccess) {
            # Since we know Regex Match was a success, extract the value using the Regex Match Name.
            Set-Variable -Name:'Result'  -Value:(
                 $RegistryKeyPathRegex.Groups  |
                     Where-Object -FilterScript { $_.Name -eq  'RegistryKeyPath'  }  |
                         Select-Object -ExpandProperty:'Value'  |
                             Out-String -NoNewLine
             )
        }
        # Cleanup all conditional variables as soon as they are no longer needed.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@('RegexMatchSuccess'))
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        Return ([System.String]$Result)
        Write-Debug -Message:'Exiting Block:  Process'
    } End {
        Write-Debug -Message: 'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-Variable -Force -ErrorAction: 'SilentlyContinue''  -Name:(@(
             'REGISTRY_KEYPATH_REGEX', 'Result', 'RegistryKeyPathRegex', 'RegexMatchSuccess'
        ))
        Write-Debug -Message: "Exiting Block:  End'
    }
}
Function Get-RegistryKeyName {
    [CmdletBinding(
        DefaultParameterSetName =  'Default',
        ConfirmImpact =  'None',
        PositionalBinding = $True
    )]
    Param(
        [Parameter( Position = 1,  ParameterSetName =  'Default', Mandatory = $True, ValueFromPipeline =
$True )]j
        [ValidateNotNulLlOrEmpty()]
        [System.String]
        $RegistryKey
    )
    Begin {
        Write-Debug -Message: 'Entering Block:  Begin'

        # Initalize STATIC Variables
        New-Variable -Name: 'REGISTRY_KEY_EXCEPTION_HASH'  -Force -Option:('Private'',  'ReadOnly') -Value:a{
            ExceptionName    =  'System.ArgumentException'
            ExceptionObject  = $RegistryKey
            ErrorId          =  'InvalidRegistryKey '
            ErrorCategory    =  'InvalidArgument'
            ExceptionMessage = $LocalizedData. InvalidRegistryKeySpecified -f $RegistryKey
        }
        # Initalize Variables
        New-Variable -Force -Option:'Private'  -Name:'Result'                -Value:([System.String]::Empty)
        New-Variable -Force -Option:'Private'  -Name: 'HasBackslash''          -Value:([System.Boolean]::Empty)
        New-Variable -Force -Option:'Private'  -Name:'RegistryKeyStr'        -Value:(  [System.String}$Null   )}
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message:'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:@('Result',  'HasBackslash',
'RegistryKeyStr' )
        # Copy the value of RegistryKey to a new object and normalize it so that we can manipulate as we want
        #     without obscutating the origional value,  a value that may be useful during debuging efforts.
        Set-Variable -Name:'Result'  -Value:([System.String](
                Get-NormalizedRegistryKeyString -RegistryKey: $RegistryKey
        ))
        # Test if the RegistryKey string has a backslash,  so we can split if needed.
        Set-Variable -Name:'HasBackslash'  -Value:(  [System.Boolean]( $Result.Contains('\') -eq $True )  )
        # Pre-Evaluate the conditional expression(s) now for easy debugging & cleaner code.
        If ($HasBackslash) {
            # Set the value of Result to all characters after the last backslash (''\').
            Set-Variable -Name:'Result'  -Value:(  [System.String](  ($Result.Split('\'))[-1]  )  )
        } Else {
            ThrowError @REGISTRY_KEY_EXCEPTION_HASH
        }
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        Return ([System.String]$Result)
        Write-Debug -Message:'Exiting Block:  Process'
    } End {
        Write-Debug -Message:'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-Variable -Force -ErrorAction: 'SilentlyContinue''  -Name:(@(
            'RegistryKey',  'REGISTRY_KEY_EXCEPTION_HASH',  ''Result',  'HasBackslash',  'RegistryKeyStr'
        ))
        Write-Debug -Message:'Exiting Block:  End'
    }
}

Function Get-RegistryResourceObject {
    [CmdletBinding(
        DefaultParameterSetName =  'Default'
        , ConfirmImpact          =  'None'
        ,  PositionalBinding     = $True
    )]
    Param(
        [Parameter( ParameterSetName =  'Default',  Position = 1, Mandatory = $True, ValueFromPipeline =
$True )]
        [ValidateNotNullOrEmpty( )]
        [System.String]
        $RegistryKey
    )
    Begin {
        Write-Debug -Message:'Entering Block:  Begin'
        # Initalize Variables
        New-Variable -Name: 'Result'           -Force -Option:('Private') -Value:(  [System.String]$Null  )
        New-Variable -Name: 'RegistryHive''     -Force -Option:('Private') -Value:(  [System.String]$Null )
        New-Variable -Name:'RegistryKeyStr'   -Force -Option:('Private') -Value:(  [System.String]$Null )
        New-Variable -Name: 'RegistryKeyPath'  -Force -Option:('Private') -Value:(  [System.String]$Null )
        New-Variable -Name: 'RegistryKeyName'  -Force -Option:('Private') -Value:(  [System.String]$Null )
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message:'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:@(
             'Result',  'RegistryKeyStr',  'RegistryHive',  'RegistryKeyPath',  'RegistryKeyName'
        )
        # Copy the value of RegistryKey to a new object and normalize it so that we can manipulate as we want
        #     without obscutating the origional value, a value that may be useful during debuging efforts.
        Set-Variable -Name:'RegistryKeyStr'  -Value:( [System.String] (
            Get-NormalizedRegistryKeyString -RegistryKey:("$RegistryKey" )
        ))
        # Get the registry hive,  if successfull, will always return a value.
        Set-Variable -Name: 'RegistryHive'  -Value:( [System.String] (
             Get-RegistryKeyHive -RegistryKey:("$RegistryKeyStr")
        ,)
        # Get the registry key path, may return an empty string.
        Set-Variable -Name: 'RegistryKeyPath'  -Value:([System.String](
             Get-RegistryKeyPath -RegistryKey:("$RegistryKeyStr")
        ,)
        # Get the registry key,  if successful, will always return a value.
        Set-Variable -Name: 'RegistryKeyName'  -Value:([System.String](
             Get-RegistryKeyName -RegistryKey:("$RegistryKeyStr")
        ))
        If ($PSCmdlet.ParameterSetName -eq  'HasValue') {
        }
        # Build the final result object.
        Set-Variable -Name:'Result'  -Value:([System.String](
            $RegistryHive +  '\'  + $RegistryKeyPath +  '\'  + $RegistryKeyName
        ))

        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        ({System.String]$Result)
        Write-Debug -Message: 'Exiting Block:  Process'
    } End {
        Write-Debug -Message: 'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
            'Result',  'RegistryKeyStr',  ''RegistryHive',  ''RegistryKeyPath',  'RegistryKeyName'
        ,)
        Write-Debug -Message:'Exiting Block:  End'
    }
}
Function Convert-ByteArrayToHexString {
    [CmdletBinding(
        DefaultParameterSetName =  'Default',
        ConfirmImpact =  'None',
        PositionalBinding = $True
    )]
    Param(
        [Parameter( Position = 1,  ParameterSetName =  'Default', Mandatory = $True, ValueFromPipeline =
$True )]
        [System.Object]
        $ByteArray
    )
    Begin {
        Write-Debug -Message: 'Entering Block:  Begin'
        # Initalize Variables
        New-Variable -Name:'Result'  -Force -Option:('Private') -Value:([System.String]$Null)
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message:'Entering Block:  Process'
        # Clear all variables immediately upon entering the  ''Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:@('Result')
        # !TODO
        $ByteArray  |
            ForEach-Object -Process:{
                g$Result += [String]::Format("{0:x2}", $_)
            }
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        ([System.String]$Result)
        Write-Debug -Message:'Exiting Block:  Process'
    } End {
        Write-Debug -Message:'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. Listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@( 'ByteArray', 'Result'))
        Write-Debug -Message:'Exiting Block:  End'
    }
}
Function Get-TypedObject {
    <# I am not happy with this function, needs a rework,  but not sure how yet. #>
    [CmdletBinding(
        DefaultParameterSetName =  'Default'

         , ConfirmImpact          =  'None'
         ,  PositionalBinding     = $True
    )] Param(
         [Parameter(ParameterSetName =  'Default',  Position = 1, Mandatory = $True,  ValueFromPipeline =
$True)]
         [Parameter(ParameterSetName =  'HasData',  Position = 1, Mandatory = $False, ValueFromPipeline =
$True)]
         [ValidateSet('String', 'ExpandString', 'MultiString', 'DWord', 'QWord', 'Binary' )]
         [System.String]
        $Type,
         [Parameter(ParameterSetName =  'HasData',  Position = 2, Mandatory = $False, ValueFromPipeline =
$True)]
         [ValidateNotNullL()]
         [System.String[]]
        $Data,
         [Parameter(ParameterSetName =  'HasData',  Position = 3, Mandatory = $False, ValueFromPipeline =
$True)]
         [ValidateNotNullOrEmpty( )]
        [Switch]
        $Hex
    )
    Begin {
        Write-Debug -Message: 'Entering Block:  Begin'
        # Initalize STATIC Variables
        New-Variable -Name: 'ARRAY_NOT_EXPECTED_EXCEPTION_HASH'  -Force -Option:('Private',  'ReadOnly') -
Value:a{
            ExceptionName    =  'System.ArgumentException'
            ExceptionObject  = $Data
            ErrorId           =  'ArrayNotExpectedForType'
            ErrorCategory    =  'InvalidArgument '
            ExceptionMessage = $localizedData.ParameterValueInvalid -f (
                 'ValueData',  (ArrayToString -Value $Data), $Type
             )
        }
        # Initalize Variables
        New-Variable -Name:'Result'  -Force -Option:('Private') -Value:([Object]$Nulll)
        Write-Debug -Message:'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message:'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue''  -Name:(@(
             'Result',  'IsNotMultiString',  'DataIsNull',  'HasMultipleStrings',  'DataWithoutHex''
        ))
        #f afsafsadfa
        If ($PSCmdlet.ParameterSetName -eq  'Default') {
            Set-Variable -Name:'DataIsNull'  -Value:([System.Boolean]($True))
        } Else {
            Set-Variable -Name:'DataIsNulL'  -Value:([System.Boolean] (
                 {[System.String]::IsNullOrEmpty($Data) -eq $True
            ))
        }
        # Determine if the
        If ($DataIsNull) {
            Switch -Regex ($Type) {
                 '4String|ExpandString$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                         New-Object -TypeName: 'System.String'  -ArgumentList:(,"")
                     )
                 }
                 *AMultiString$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                         New-Object -TypeName: 'System.String[]'  -ArgumentList:(,$null)
                     )

                }
                 '*Dword$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                        New-Object -TypeName: 'System.Int32'  -ArgumentList:($null)
                     )
                }
                 "AQword$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                         New-Object -TypeName: 'System.Int64'  -ArgumentList:($null)
                     )
                }
                 '*Binary$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                         New-Object -TypeName: 'system.byte[]'  -ArgumentList:(,$null)
                     )
                }
            }
        } Else {
            # If the  '$Type'  object is not a multistring object, then we should always expect that  '$Data'
should
            #     only be a single string instance as all other object types can only hold a single value.
            Set-Variable -Name:'IsNotMultiString'    -Value:([System.Boolean]($Type -ine  'MultiString' ))
            Set-Variable -Name:'HasMultipleStrings'  -Value:([System.Boolean]($Data.count -gt 1))
            If ($IsNotMultiString -and $DataIsNull -and $HasMultipleStrings) {
                ThrowError @ARRAY_NOT_EXPECTED_EXCEPTION_HASH
            }
            Switch -Regex ($Type) {
                 '"String|ExpandString$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                         New-Object -TypeName: 'System.String'  -ArgumentList:($Data[@])
                     )
                }
                 'AmultiString$'  {
                    Set-Variable -Name:'Result'  -Force -Value:(
                         New-Object -TypeName: 'System.String'  -ArgumentList:(,$Data)
                     )
                 }
                 '"Dword|QwWord|Binary$'  {
                    Set-Variable -Name:'HexSpecStr'  -Value:($Data[@].TrimStart('0x'))
                    If ($Hex) {
                         Set-Variable -Name:'IntParseNumerStyle'  -Value:(
                             [System.Globalization.NumberStyles]::AllowHexSpecifier
                         )
                         Set-Variable -Name:'IntParseError'  -
Value: ($VALUE_DATA_NOT_IN_HEX_FORMAT_HASH_EXCEPTION)
                     } Else {
                         Set-Variable -Name:'IntParseNumerStyle''  -
Value: ([System.Globalization.NumberStyles]::Any)
                         Set-Variable -Name:'IntParseError' -Value: ($INVALID_INT_VALUE_HASH_EXCEPTION )
                     }
                 }
                 '*Dword$'  {
                         Try {
                             Set-Variable -Name:'Result'  -Value:(
                                 (System.Int32]::Parse(
                                     $HexSpecStr,
                                     $IntParseNumerStyle,
                                     {System.Globalization.CultureInfo]::CurrentCulture
                                 )
                             )
                         } Catch {
                             ThrowError @IntParseError
                         }
                }
                 "*qword$'  {
                    Try {
                         Set-Variable -Name:'Result'  -Value:(
                             [System.Int64]::Parse(

                                 $HexSpecStr,
                                 $IntParseNumerStyle,
                                 [System.Globalization.CultureInfo]::CurrentCulture
                             )
                         )
                     } Catch {
                         ThrowError @IntParseError
                     }
                 }
                 "*Binary$'  {
                     If (($HexSpecStr.Length % 2) -ne 0) {
                         Set-Variable -Name:'HexSpecStr'  -Value: (
                             $HexSpecStr.PadLeft($HexSpecStr.Length + 1,  @)
                         )
                     }
                     Try {
                         Set-Variable -Name:'Result'  -Force -Value:(
                             New-Object -TypeName:'system.byte[]'  -ArgumentList:(,$null)
                         )
                         For ($I = 0;  $I -lt ($HexSpecStr.Length -1);  $I = $I + 2) {
                             Set-Variable -Name: 'Result'  -Value:(
                                 $Result += ([System.Byte]::Parse(
                                     $HexSpecStr.Substring($I,  2),
                                     [System.Globalization.NumberStyles]::HexNumber,
                                     [System.Globalization.CultureInfo]::CurrentCulture
                                 ))
                             )
                         }
                     } Catch {
                         throw $_
                         #ThrowError @VALUE_DATA_NOT_IN_HEX_FORMAT_HASH_EXCEPTION
                     }
                 }
            }
        }
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        $Result
        Write-Debug -Message: 'Exiting Block:  Process'
    } End {
        Write-Debug -Message: 'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function,  but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@( 'ByteArray', 'Result'))
        Write-Debug -Message:'Exiting Block:  End'
    }
}
Function Get-TargetResource {
    <#H>
    [CmdletBinding(
        DefaultParameterSetName =  'Default'
        , ConfirmImpact          =  'None'
        ,  PositionalBinding     = $True
    }]  Param(
        [Parameter(ParameterSetName =  'Default',   Position = 1, Mandatory = $True, ValueFromPipeline =
$True)]
        [Parameter(ParameterSetName =  ''HasValue',  Position = 1, Mandatory = $True, ValueFromPipeline =
$True)]
        [System.String]
        $RegistryKey,
        [Parameter(ParameterSetName =  'HasValue',  Position = 2, Mandatory = $True, ValueFromPipeline =
$True)]

        [ValidateNotNull()]
        [System.String]
        $ValueName
    )
    Begin {
        Write-Debug -Message:'Entering Block:  Begin'
        # Initalize Variables
        New-Variable -Name: 'Result'                  -Force -Option:('Private') -
Value: ([System.Collections .Hashtable]$Null)                                                         ;
        New-Variable -Name: 'RegistryEnsure'          -Force -Option:('Private') -Value:([System.String]$Null)
        New-Variable -Name: 'RegistryKeyStr'          -Force -Option:('Private') -Value:([System.String]$Null)
        New-Variable -Name: 'RegistryKeyExists'       -Force -Option:('Private') -Value:([System.Boolean]$Null)
        New-Variable -Name: 'RegistryKeyObj''          -Force -Option:('Private') -
Value: ( [Microsoft.Win32.RegistryKey]$Null)
        New-Variable -Name:'RegistryKeyValueNames'   -Force -Option:('Private') -
Value: ([System.String[]]$Null)
        New-Variable -Name: 'RegistryKeyValueExists'  -Force -Option:('Private') -Value:([System.Boolean]$Null)
        New-Variable -Name: 'RegistryValueName '       -Force -Option:('Private') -Value:([System.String]$Null)
        New-Variable -Name: 'RegistryValueKind'       -Force -Option:('Private') -
Value: ((Microsoft.Win32.RegistryValueKind]::Unknown)
        New-Variable -Name: 'RegistryValueData'       -Force -Option:('Private') -Value:($Null)
        Write-Debug -Message: 'Exiting Block:  Begin'
    } Process {
        Write-Debug -Message: 'Entering Block:  Process'
        # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale values are
        #     carried over between piped datasets.
        Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
             'Result',  'RegistryEnsure',  'RegistryKeyStr'',  'RegistryKeyExists',  'RegistryKeyObj',
             'RegistryKeyValueNames',  'RegistryKeyValueExists',  'RegistryValueName',  'RegistryValueKind',
             'RegistryValueData'
        ))
        # Define default values for key variables to ensure consistency and streamline execution flow.
        Set-Variable -Name:'RegistryEnsure'  -Value:'Absent'
        # Run the Provider Setup function, which parses and normalizes the Registry Key string and ensures
that
        #     the necessary registry hive is mounted ensuring consistency across the rest of the execution `
        Set-Variable -Name:'RegistryKeyStr'  -Value:([System.String](
            Start-ProviderSetup -RegistryKey: ($RegistryKey)
        ))
        # Ensure Key Exists
        Set-Variable -Name: 'RegistryKeyExists'  -Value:([System.Boolean](
            Test-Path -Path:('Registry::{0}'  -f $RegistryKeyStr)
         ))
        # If the registry key exists, we can either report that as  'Present'  or check the status of the key
        #     ValueName,  if it was provided,  and report as such, otherwise it will keep default value of
'Absent'.
        If ($RegistryKeyExists) {
            If ($PSCmdlet.ParameterSetName -eq  'Default') {
                    # No Registry ValueName was provided,  so just report presense of Registry Key.
                    Set-Variable -Name:'RegistryEnsure'  -Value:'Present'
            } ElseIf ($PSCmdlet.ParameterSetName -eq  'HasValue') {
                #
                Set-Variable -Name:'RegistryValueName'  -Value:([System.String](
                    $ValueName
                ))
                # Query the Registry Key Obj
                Set-Variable -Name: 'RegistryKeyObj'  -Value:((Microsoft.Win32.RegistryKey](
                        Get-Item -Path:('Registry::{0}'  -f $RegistryKeyStr)
                ))

                 # Get a List of all registry key value names.  Need to use the  'GetValueNames()' method
instead
                 #     if just inspecting the  ''Properties'  property because a emptry string (i.e.  '(Default)')
                #     will not match properly unless you use  'GetValueNames()'.
                Set-Variable -Name: 'RegistryKeyValueNames'  -Value:([System.String[]](
                     $RegistryKeyObj.GetValueNames( )
                 ))
                # Check for the existance of the Registry Key Value in the Registry Key.
                Set-Variable -Name: 'RegistryKeyValueExists'  -Value:([System.Boolean](
                     $RegistryValueName -in $RegistryKeyValueNames
                 ,)
                 If ($RegistryKeyValueExists) {
                     # The Registry Value exists,  so we can report it as  'Present'.
                     Set-Variable -Name:'RegistryEnsure'  -Value: 'Present'
                     # If the Registy Value is an empty string, we presume it represents the  'Default'  value
of the
                     #    registry key,  so we localize the text to make the output easier for anyone using or
                     #    reviewing the script and its various outputs.
                     If ($RegistryValueName -eq [System.String]::Empty) {
                         Set-Variable -Name: 'RegistryValueName'  -Value:([System.String]}(
                             $localizedData.DefaultValueDisplayName
                         ))
                     }
                     Set-Variable -Name:'RegistryValueKind'  -Value:([Microsoft.Win32.RegistryValueKind](
                         $RegistryKeyObj.GetValueKind( $RegistryValueName )
                     ))
                     Set-Variable -Name: 'RegistryValueData'  -Value:((
                         $RegistryKeyObj.GetValue(
                             {System.String ]$RegistryValueName,
                             $null,
                             [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
                         )
                     ))
                 }
            }
        }
        # Now that we have all parts of the registry key properly parsed, build
        #     the final object we will return at the end of the function.
        Set-Variable -Name:'Result'  -Value:(
            [Hashtable]@{
                Ensure    = [System.String]$RegistryEnsure;
                Key       = [System.String]$RegistryKeyStr;
                ValueName = [System.String]$RegistryValueName;
                ValueKind = [System.String]$RegistryValueKind;
                ValueData = [System.String]$RegistryValueData;
            }
        )
        # Do a  'soft'  return by sending the Result object to the caller and explicitly declare the returning
        #     the result with a explicit typing to ensure all returned data types are predictable.
        ([Hashtable]$Result)
        Write-Debug -Message: 'Exiting Block:  Process'
    } End {
        Write-Debug -Message:'Entering Block:  End'
        # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't technically
        #     required as they will automatically be disposed of when leaving a function, but I consider
        #     this best practice as it forces me to be mindful of all used variables.
        Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
             'Result',  'RegistryEnsure',  'RegistryKeyStr',  'RegistryKeyExists',  'RegistryKeyObj',
             'RegistryKeyValueNames',  'RegistryKeyValueExists',  'RegistryValueName',  ''RegistryValueKind',
             'RegistryValueData'
        ))

Write-Debug -Message: 'Exiting: Block:  End'        tens                     os       oe                           |
