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
