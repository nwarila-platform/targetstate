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
