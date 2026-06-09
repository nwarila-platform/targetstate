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
