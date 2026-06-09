Function Start-ProviderSetup {
  [CmdletBinding(
       ConfirmImpact            =  'Low'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
    , SupportsShouldProcess   = $True
  )]  Param(
    [Parameter(
        Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [PSCustomObject]
    $InputObject
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize STATIC Variable(s)
    New-Variable -Force -Option:('Private',  'ReadOnly') -Name:'ALL_REQUIRED_PROPERTIES'  -Value:(
      [System.Array] (
           'KeyHive',  'KeyName'
      )
    )
    # Initalize DYNAMIC Variable(s)
    New-Variable -Force -Option:'Private'  -Name: 'Result'     -Value:($Null)
    New-Variable -Force -Option:'Private'  -Name: 'KeyName'    -Value: ([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'KeyHive'    -Value: ([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'KeyPath'    -Value:([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'ValueName'  -Value:([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'ValueKind'  -Value:([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'ValueData'  -Value:([System.String]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:([System.Array](
      'Result',  'KeyHive',  'KeyName',
      'KeyPath',  'ValueName',  'ValueKind',  'ValueData'
    ))
    # Validate that each required property exists and
    ForEach ($RequiredProperty in $ALL_REQUIRED_PROPERTIES) {
      If ($InputObject.PSObject.Properties.Name -notcontains $RequiredProperty) {
        # <#OCR-UNREADABLE#>
        ThrowError                                   `
          -ErrorId: 'ParameterRequired'               `
          -ErrorCategory: 'InvalidArgument' `
          -ExceptionName: 'System.ArgumentException' `
          -ExceptionObject: $RequiredProperty         `
          -ExceptionMessage:($LocalizedData.ParameterRequired -f  $RequiredProperty)
      }
    }
    # Itterate through each of the optional arguments and parse them as needed.
    Switch ($InputObject.PSObject.Properties.Name) {
      'KeyHive'  {
        Set-Variable -Name:'KeyHive'  -Value:([Hashtable] (
          Get-RegistryKeyHiveObj -KeyHive:$InputObject.KeyHive
        ))
      }
      'KeyName'  {
        Set-Variable -Name:'KeyName'  -Value:([System.String](
          Get-RegistryKeyNameStr -KeyName: $InputObject.KeyName
        ))

      }
      'KeyPath'  {
        Set-Variable -Name:'KeyPath'  -Value:([System.String](
          Get-RegistryKeyPathStr -KeyPath:$InputObject.KeyPath
        ))
      }
      'ValueName'  {
        Set-Variable -Name:'ValueName'  -Value:([System.String](
          Get-RegistryValueNameStr -ValueName: $InputObject.ValueName
        ))
      }
      'ValueKind'  {
        Set-Variable -Name:'ValueKind'  -Value:([Microsoft.Win32.RegistryValueKind] (
          Get-RegistryValueKindStr -ValueKind:$InputObject.ValueKind
        ))
      }
      'ValueData'  {
        Set-Variable -Name:'ValueData'  -Value:([System.String](
          $InputObject.ValueData
          # Get-RegistryValueData `
          #   -Type:$InputObject.ValueKind `
          #   -Data:$InputObject.ValueData
        ))
      }
      default {
        Write-Warning -Message:"Unexpected Property:  '$($_)'"
      }
    }
    # Ensure that the Registry Hive is mounted and accessible.
    Mount-RegistryHive -RegistryHive:($KeyHive)
    # Build the final object we will be returning to the caller.
    Set-Variable -Name:'Result'  -Value:([PSCustomObject]@{
      RegistryKeyHive   = $KeyHive
      RegistryKeyPath   = $KeyPath
      RegistryKeyName   = $KeyName
      RegistryValueName = $ValueName
      RegistryValueKind = $ValueKind
      RegistryValueData = $ValueData
    })
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    ([PSCustomObject]$Result)
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  Listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:([System.Array](
      'Result',  'KeyHive',  'KeyName',
      'KeyPath',  'ValueName',  'ValueKind',  'ValueData'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
