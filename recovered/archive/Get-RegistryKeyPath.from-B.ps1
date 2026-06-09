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
