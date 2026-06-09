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
