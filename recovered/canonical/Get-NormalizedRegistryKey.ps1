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
