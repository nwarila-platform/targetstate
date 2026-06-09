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
