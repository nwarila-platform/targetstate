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
