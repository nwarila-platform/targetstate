Function Start-ProviderSetup {
  [CmdletBinding(
    ,  ConfirmImpact            =  'Low'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
    , SupportsShouldProcess   = $True
  )]  Param(
    [Parameter(
      , Mandatory          = $True
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
        ,  'KeyHive',  'KeyName'
      )
    )
    # Initalize DYNAMIC Variable(s)
    New-Variable -Force -Option:'Private'  -Name: 'Result'     -Value:([PSCustomObject]::Empty)
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
      'Result',  'RegistryKey',  'KeyHive',  'KeyName',
      'KeyPath',  'ValueName',  'ValueKind',  'ValueData'
    ))
    # Validate that each required property exists and
    ForEach ($RequiredProperty in $ALL_REQUIRED_PROPERTIES) {
      If ($InputObject.PSObject.Properties.Name -notcontains $RequiredProperty) {
        # ee oe ww coe oe is eT ps toe a ett sp em in es den tp en es ne oe we ewe om
        ThrowError                                   `
          -ErrorId: 'ParameterRequired'               `
          -ErrorCategory: 'InvalidArgument' `
          -ExceptionName: 'System.ArgumentException' `
          -ExceptionObject: $RequiredProperty         `
          -ExceptionMessage:($LocalizedData.ParameterRequired -f  'Something')
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
    Set-Variable -Name:'Result'  -Value:([PSCustomObject ]@{
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
      'Result',  'RegistryKey',  'KeyHive',  'KeyName',
      'KeyPath',  'ValueName',  'ValueKind',  'ValueData'
    ))
  ; Write-Debug -Message:'Exiting Block:  End'
}
Function Get-RegistryKeyHiveObj {
  [CmdletBinding(
    ,  ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True

    ,  ParameterSetName  =  'Default'
    ,  Position           = 0
    , ValueFromPipeline = $True
  )]
  [ValidateNotNullOrEmpty()]
  [System.String]
  $KeyHive
)
Begin {
  Write-Debug -Message:'Entering Block:  Begin'
  # Initalize DYNAMIC Variables
  New-Variable -Force -Option:'Private'  -Name:'Result'        -Value:([System.String]::Empty)
  New-Variable -Force -Option:'Private'  -Name:'RegistryHive'  -Value:([Hashtable]::Empty)
  Write-Debug -Message:'Exiting Block:  Begin'
} Process {
  Write-Debug -Message:'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:([System.Array](
    'Result',  'RegistryHive'
  ))
  Switch ($KeyHive) {
    { $PSItem -in @(,  'HKCR',  'HKEY_CLASSES ROOT',  'ClassesRoot',  '-2147483648') } {
      Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_CLASSES_ROOT'
        ShortName    =  'ClassesRoot'
        Abbreviation =  'HKCR'
      })
    }
    { $PSItem -in @(,  'HKCU',  'HKEY_CURRENT_USER',  'CurrentUser',  '-2147483647') } {
      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_CURRENT_USER'
        ShortName    =  'CurrentUser'
        Abbreviation =  'HKCU'
      })
    }
    { $PSItem -in @(,  'HKLM',  'HKEY_LOCAL_MACHINE',  'LocalMachine',  '-2147483646') } {
      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_LOCAL_MACHINE'
        ShortName    =  'LocalMachine'
        Abbreviation =  'HKLM'
      })
    }
    { $PSItem -in @(,  'HKU',  'HKEY_USERS',  'Users',  '-2147483645')  } {
      Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_USERS'
        ShortName    =  'Users'
        Abbreviation =  'HKU'
      })
    }
    { $PSItem -in @(,  'HKPD',  'HKEY_PERFORMANCE_DATA',  'PerformanceData',  '-2147483644') } {
      Set-Variable -Name: 'RegistryHive'  -Value:([Hashtable]@{
        Name          =  'HKEY_PERFORMANCE_DATA'
        ShortName    =  'PerformanceData'
        Abbreviation =  'HKPD'
      })
    }
    { $PSItem -in @(,  'HKCC',  'HKEY_CURRENT_CONFIG',  'CurrentConfig',  '-2147483643') } {
      Set-Variable -Name:'RegistryHive'  -Value:([Hashtable]a{
        Name          =  'HKEY_CURRENT_CONFIG'
        ShortName    =  'CurrentConfig'
        Abbreviation =  'HKCC'
      })
    }
    default {
      ThrowError `
        -ErrorId: 'InvalidRegistryHiveSpecified' `
        -ErrorCategory: 'InvalidArgument ' `

          -ExceptionName: 'System.ArgumentException' `
          -ExceptionObject:$KeyHive `
          -ExceptionMessage: $LocalizedData. InvalidRegistryHiveSpecified
      }
    }
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name:'Result'  -Value:([Hashtable](
      $RegistryHive
    ))
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
            'KeyHive',  'Result',  'RegistryHive'
        ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
Function Get-RegistryKeyPathStr {
  [CmdletBinding(
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
    , ConfirmImpact            =  'None'
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [ValidateNotNull()]
    [System.String]
    $KeyPath
  )
  Begin {
      Write-Debug -Message:'Entering Block:  Begin'
      # Initalize DYNAMIC Variables
      New-Variable -Force -Option:'Private'  -Name:'Result'                   -Value:([System.String]::Empty)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasNonPrintChars'  -Value:([System.Boolean]::Empty)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasDoubleSlashes'  -Value:([System.Boolean]::Empty)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasLeadingSlash'   -Value:([System.Boolean]::Empty)
      New-Variable -Force -Option:'Private'  -Name:'KeyPathHasTrailingSlash'  -Value:([System.Boolean]::Empty)
      Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
      Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #   values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(@(
      'Result',  'KeyPathHasNonPrintChars',  'KeyPathHasDoubleSlashes',
      'KeyPathHasLeadingSlash',  'KeyPathHasTrailingSlash'
     )
    # Key names cannot any non-printable characters.

  Set-Variable -Name:'KeyPathHasNonPrintChars'  -Value:([System.Boolean](
    $KeyName -match  '\P{Cc}\p{Cn}\p{cs}'
  ))
  If ($KeyPathHasNonPrintChars -eq $True) {
    ThrowError `
      -ErrorId: 'InvalidRegistryKeyName ' `
      -ErrorCategory: 'InvalidArgument' `
      -ExceptionName: 'System.ArgumentException' `
      -ExceptionObject:$KeyPath `
      -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
  }
  Set-Variable -Name: 'NormalizedKeypath'  -Value:([System.String](
    $KeyPath
  ))
  Set-Variable -Name:'KeyPathHasDoubleSlashes'  -Value:([System.Boolean] (
    $NormalizedKeypath -match ('\\{2,}')
  ))
  If ($KeyPathHasDoubleSlashes -eq $True) {
    Set-Variable -Name: 'NormalizedKeypath'  -Value:([System.String](
      $NormalizedKeypath -replace ('\\+',  '\')
    ))
  }
  Set-Variable -Name:'KeyPathHasLeadingSlash'  -Value:([System.Boolean] (
    $NormalizedKeypath[@] -eq  '\'
  ))
  If ($KeyPathHasLeadingSlash -eq $True) {
    Set-Variable -Name:'NormalizedKeypath'  -Value:([System.String](
      $NormalizedKeypath.Substring(1)
    ))
  }
  Set-Variable -Name:'KeyPathHasTrailingSlash'  -Value:([System.Boolean](
    $NormalizedKeypath[-1]  -eq  '\'
  ))
  If ($KeyPathHasTrailingSlash -eq $True) {
    Set-Variable -Name: 'NormalizedKeypath'  -Value:([System.String](
      $NormalizedKeypath.TrimEnd('\' )
    ))
  }
  # It's always desirable to explicitly set the Result object with its desired class as close
  #   to the soft return to ensure the output is predictable and easily traceable.
  Set-Variable -Name:'Result'  -Value:([System.String] (
    $NormalizedKeypath
  ))
  # Do a  'soft'  return by outputting the result to the pipe without using the return function
  #   which would immediately end the function,  this enables us to have the very last
  #   executing item be write-debug giving us a valuable breakpoint & enabling better
  #   debugging functionality and output.
  $Result
  Write-Debug -Message:'Exiting Block:  Process'
} End {
  Write-Debug -Message:'Entering Block:  End'
  # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't
  #   technically required as they will automatically be disposed of when leaving a function,
  #   but I consider this best practice as it forces me to be mindful of all used variables.
  Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:([System.Array](
    'Result',  'KeyPathHasNonPrintChars',  'KeyPathHasDoubleSlashes',
    'KeyPathHasLeadingSlash',  'KeyPathHasTrailingSlash',  'KeyName'
  ))
  Write-Debug -Message:'Exiting Block:  End'
}

}
Function Get-RegistryKeyNameStr {
  [CmdletBinding(
    ,  ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [ValidateNotNullOrEmpty()]
    [System.String]
    $KeyName
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'Result'                   -Value:( [System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'KeyNameHasBackslash'      -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'KeyNameHasNonPrintChars'  -Value:([System.Boolean]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'Result',  'KeyNameHasBackslash',  'KeyNameHasNonPrintChars'
    ))
    # Key names cannot include the backslash ('\') character.
    Set-Variable -Name: 'KeyNameHasBackslash'  -Value:([System.Boolean] (
      $KeyName.Contains('\')
    ))
    If ($KeyNameHasBackslash -eq $True) {
      ThrowError `
        -ErrorId: 'InvalidRegistryKeyName' `
        -ErrorCategory: 'InvalidArgument' `
        -ExceptionName: 'System.ArgumentException'' `
        -ExceptionObject: $KeyName `
        -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
    }
    # Key names cannot any non-printable characters.
    Set-Variable -Name:'KeyNameHasNonPrintChars'  -Value:([System.Boolean] (
      $KeyName -match  '\P{Cc}\p{Cn}\p{Cs}'
    ))
    If ($KeyNameHasNonPrintChars -eq $True) {
      ThrowError `
        -ErrorId: 'InvalidRegistryKeyName' `
        -ErrorCategory: 'InvalidArgument' `
        -ExceptionName: 'System.ArgumentException' `
        -ExceptionObject: $kKeyName `
    :   -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name:'Result'  -Value:( [System.String] (
      $KeyName
    ))
    # Do a  'soft'  return by outputting the result to the pipe without using the return function

    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  listed) and cleaned up. This isn't
    # =  technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
      'KeyName',  'Result',  'KeyNameHasBackslash',  'KeyNameHasNonPrintChars'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
Function Get-RegistryValueNameStr {
  [CmdletBinding(
    , ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [AllowEmptyString()]
    [ValidateNotNull()]
    [System.String]
    $ValueName
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'Result'          -Value: ([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'IsNonPrintable'  -Value:([System.Boolean]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #   values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(@(
      'Result',  'IsNonPrintable'
    ))
    # Key names cannot any non-printable characters.
    Set-Variable -Name:'IsNonPrintable'  -Value:([System.Boolean](
      $ValueName -match  '\P{Cc}\p{Cn}\p{cs}'
    ))
    If ($IsNonPrintable -eq $True) {
      # mn wwe ce wen oa cp nmr tem cin on cam cam wo um: mm came am Me ah sO OSs i ee oe  ee ee
      ThrowError `
        -ErrorId: 'InvalidRegistryKeyName ' `
        -ErrorCategory: 'InvalidArgument' `
        -ExceptionName: 'System.ArgumentException' `
        -ExceptionObject :$ValueName `
        -ExceptionMessage: $LocalizedData.InvalidRegistryKeyNameSpecified
    }
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.

    Set-Variable -Name:'Result'  -Value:([System.String](
      $ValueName
    ))
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message: 'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'KeyName',  'Result',  'KeyNameHasBackslash',  'KeyNameHasNonPrintChars'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
Function Get-RegistryValueKindStr {
  [CmdletBinding(
    DefaultParameterSetName =  'Default'
    ,  PositionalBinding     = $True
    ,  ConfirmImpact          =  'None'
  )]
  Param(
    [Parameter(
      ParameterSetName  =  'Default',
      Position           = 0,
      Mandatory          = $True,
      ValueFromPipeline = $True
    )]
    [AllowEmptyString()]
    [ValidateNotNull()]
    [System.String]
    $ValueKind
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'IsValidValueKind'        -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'NormalizedValueKind'     -
Value:([Microsoft.Win32.RegistryValueKind]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'ValueKindIsUnknown'      -
Value:([Microsoft.Win32.RegistryValueKind]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'Result'                  -
Value:([Microsoft.Win32.RegistryValueKind]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
       'ValueKindIsNullorEmpty',  'IsValidValueKind',  'NormalizedValueKind',
       'ValueKindIsUnknown',  'Result'
    ))
    Set-Variable -Name:'ValueKindIsNullorEmpty'  -Value:([System.Boolean] (
      [System.String]::IsNullOrWhiteSpace($ValueKind)
    ))
    If ($ValueKindIsNullorEmpty -eq $True) {

      Set-Variable -Name: 'NormalizedValueKind'  -Value:(
        [Microsoft.Win32.RegistryValueKind]::None
      )
    } Else {
      # Validate the Registry Hive value against a list of valid and support registry hives.
      Set-Variable -Name:'IsValidValueKind'  -Value: (
        [System.Boolean] (
          [Enum]::TryParse(
             [Microsoft.Win32.RegistryValueKind],
            $ValueKind,
            [Ref ]$NormalizedValueKind
          )
        )
      )
      # While  'Unknown'  is a valid RegistryValueKind,  it's not a relevant value for our function
      #   so we treat it as Invalid and raise an exception.
      Set-Variable -Name:'ValueKindIsUnknown'  -Value:(
        [System.Boolean] (
          $NormalizedValueKind -eq  'Unknown'
        )
      )
      # If the Registry Key Value Type is invalid,  raise am error and exit the function.
      If (($IsValidValueKind -eq $False) -or ($ValueKindIsUnknown -eq $True)) {
        ThrowError `
          -ErrorId: 'InvalidRegistryValueTypeSpecified' `
          -ErrorCategory: 'InvalidArgument' `
          -ExceptionName: 'System.ArgumentException' `
          -ExceptionObject:$ValueKind `
          -ExceptionMessage: $LocalizedData.InvalidRegistryValueTypeSpecified
      }
    } #else
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name: 'Result'  -Value:(
      [Microsoft.Win32.RegistryValueKind](
        $NormalizedValueKind
      )
    )
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e.  listed) and cleaned up.  This isn't
    # =  technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
      'ValueKindIsNullorEmpty',  'IsValidValueKind',  'ValueKind',
      'ValueKindIsUnknown',  'Result',  'NormalizedValueKind'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
} #Function Get-RegistryValueKindStr
Function Mount-RegistryHive {
  [CmdletBinding(
    ,,  ConfirmImpact            =  'Low'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True

  ,  SupportsShouldProcess   = $True
)]
Param(
  [Parameter(
    , Mandatory          = $True
    ,  ParameterSetName  =  'Default'
    ,  Position           = 0
    , ValueFromPipeline = $True
  )]
  [ValidateNotNullOrEmpty( )]
  [Hashtable]
  $RegistryHive
)
Begin {
  Write-Debug -Message:'Entering Block: Begin'
  # Initalize Variables
  New-Variable -Name: 'Result'               -Force -Option:('Private') -Value:( $Null  )
  New-Variable -Name:'RegistryKeyStr'       -Force -Option:('Private') -Value:(  [System.String]::Empty   )
  New-Variable -Name:'ShouldMountRegistry'  -Force -Option:('Private') -Value:(  [System.Boolean]::Empty )
  New-Variable -Name: 'RegistryIsMounted'    -Force -Option:('Private') -Value:(  [System.Boolean]::Empty )
  Write-Debug -Message:'Exiting Block:  Begin'
} Process {
  Write-Debug -Message:'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:@(
    'Result',  'ShouldMountRegistry',  'RegistryIsMounted'
  )
  # Test to see if the Registry Hive is mounted.
  Set-Variable -Name: 'ShouldMountRegistry'  -Value:(
    [System.Boolean] (
      (Test-Path -Path:('Registry::{0}'  -f $RegistryHive.Abbreviation)) -eq $False
    )
  )
  If ($ShouldMountRegistry) {
    If ($PSCmdlet.ShouldProcess(''),  $null,  $null) {
      Try {
        # ---------------------------------- J
        New-PSDrive `
          -Name:($RegistryHive.Abbreviation) `
          -PSProvider:('Registry') `
          -Scope:('Script') `
          -Root: ($RegistryHive.Name)
      } Catch {
        Throw $_
      }
    }
  }
  # Recheck the value attempting to mount PSDrive
  Set-Variable -Name:'RegistryIsMounted'  -Value:([System.Boolean] (
    Test-Path -Path:('Registry::{0}'  -f $RegistryHive.Abbreviation)
  ))
  # If registry is not correctly mounted,  then we need to throw an error.
  If ($RegistryIsMounted -eq $False) {
      Throw "Unable to mount registry"
      # ThrowError                                  `
      #     -ErrorId: 'InvalidRegistryKeyName ' `
      #     -ErrorCategory: 'InvalidArgument' `
      #     -ExceptionName: 'System.I0.IOException' `
      #     -ExceptionObject:$RegistryKey `
  ;   #     -ExceptionMessage: $LocalizedData. InvalidRegistryKeyNameSpecified
  # It's always desirable to explicitly set the Result object with its desired class as close
  #   to the soft return to ensure the output is predictable and easily traceable.
  Set-Variable -Name:'Result'  -Value:([System.Nullable]$Null)

    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message:'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e. Listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
             'RegistryKey',  'REGISTRY_NAME',  'Result',  'RegistryKeyStr',  'ShouldMountDrive'
         ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
#region ------  [ Active Development ] -------------------------------------------------------- %#
Function Get-TargetResource {
  [CmdletBinding(
     ,  ConfirmImpact            =  'None'
     ,  DefaultParameterSetName =  'Default'
     ,  PositionalBinding        = $True
  )]
  Param(
    [Parameter(
       , Mandatory          = $True
       ,,  ParameterSetName  =  'Default'
       ,,  Position           = 0
       , ValueFromPipeline = $True
    )]
    [PSCustomObject]
    $InputObject
  )
  Begin {
    Write-Debug -Message:'Entering Block:  Begin'
    # Initalize DYNAMIC Variables
    New-Variable -Force -Option:'Private'  -Name:'Result'               -Value:([System.String]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'IsFriendlyRegHive'    -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'IsValidRegHive'       -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryKeyExists'    -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryValueExists'  -Value:([System.Boolean]::Empty)
    New-Variable -Force -Option:'Private'  -Name:'KeyValueProvided'     -Value:([System.Int32]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryHive'         -
Value: ([Microsoft.Win32.RegistryKey]::Empty)
    New-Variable -Force -Option:'Private'  -Name: 'RegistryKey'          =
Value: ([Microsoft.Win32.RegistryKey]::Empty)
    Write-Debug -Message:'Exiting Block:  Begin'
  } Process {
    Write-Debug -Message:'Entering Block:  Process'
    # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
    #    values are carried over between piped datasets.
    Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(
      [System.Array](
         'Result',  'RegistryHive',  'RegistryKey',  'IsFriendlyRegHive',  'IsValidRegHive'
      )
    )
    # Create a RegistryKey object open to target registry hive.
    Set-Variable -Name: 'RegistryHive'  -Value:(
      [Microsoft.Win32.RegistryKey]::OpenBaseKey(
        [Microsoft.Win32.RegistryHive]::"$($InputObject.RegistryKeyHive.ShortName)",
        [Microsoft.Win32.RegistryView]::Default
      )

)
# Create a RegistryKey object open to target registry key with minimal permissions.
Set-Variable -Name: 'RegistryKey'  -Value:(
  $RegistryHive. OpenSubKey(
    ('{0}\{1}'  -f $InputObject.RegistryKeyPath,  $InputObject.RegistryKeyName),
    [Microsoft.Win32.RegistryKeyPermissionCheck]::Default,
    [System.Security.AccessControl.RegistryRights]::QueryValues
  )
)
# Check to
Set-Variable -Name:'RegistryKeyExists'  -Value:([System.Boolean] (
    ($Null -eq $RegistryKey) -eq $False
))
# RegistryKey will be equal to null if the key does not exist.
If ($RegistryKeyExists -eq $True) {
  # Check each property if they are Null or Empty,  then convert the boolean to a int, which
  #   results in  'False = 0'  and  'True = 1',  then multiply that by bit values so we can
  #   accurately predict the value combination using basic INT value checks.
  Set-Variable -Name:'KeyValueProvided'  -Value:([System.Int32](
    ([System.Int32]( [System.String]::IsNullOrEmpty($InputObject.RegistryValueName) -eq $False) * 1) +
    ([System.Int32]([System.String]::IsNullOrEmpty($InputObject.RegistryValueKind) -eq $False) * 2)
  ))
  Switch ($KeyValueProvided) {
    # If $PSItem = 0,  then both key values are empty.
    { $PSItem -eq 0 } {
      # We do not need to check the key value.
      Write-Debug -Message: (
         "KeyValue, ValueName,  and ValueData all empty,  only reporting registry key status.'
      )
    }
    # RegistryValueType HAS been provided,  RegistryValueData might have been provided. This
    #   means the user is likely targetting the  'default'  key,  but we need to confirm
    #   RegistryValueType is configured as  'REG_SZ'  to confirm.
    { $PSItem -eq 2  } {
      Set-Variable -Name: 'RegistryValueKindIsString'  -Value:([System.Boolean] (
        $InputObject.RegistryValueKind -eq  [Microsoft.Win32.RegistryValueKind]::String
      ))
      # If value kind is  'string', we are can be reasonably confident the user meant to target
      #   the  'default'  key.
      If ($RegistryValueKindIsString -eq $True) {
        Set-Variable -Name: 'RegistryValueData'  -Value: (
          $RegistryKey.GetValue('')
        )
      }
    } #end:  {$ PSItem -eq 2 }
    # All 3 required variables were provided,  so now we just query the values we need.
    { $PSItem -eq 3 } {
      # Test to see if the Registry Key Value exists.
      Set-Variable -Name: 'RegistryValueExists'  -Value:([System.Boolean] (
        $RegistryKey.GetValueNames() -contains $InputObject.RegistryValueName
      ))
      # If the registry value exists, we then need to query the values of RegistryValueType and
      #   RegistryValueData
      If ( $RegistryValueExists -eq $True ) {
        Set-Variable -Name: 'RegistryValueData'  -Value:(
          $RegistryKey.GetValue(
            $InputObject.RegistryValueName,
            $null,
            [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames

               )
             )
            Set-Variable -Name:'RegistryValueKind'  -Value: (
               [Microsoft.Win32.RegistryValueKind](
                 $RegistryKey.GetValueKind($InputObject.RegistryValueName )
               )
             )
          }
        } #end:  { $PSItem -eq 3 }
        default {
          # If we reach here, we changed the  'KeyValueProvided'  variable in some meaningful way.
        }
      } #end:  Switch ($KeyValueProvided)
    } #end:  If ($RegistryKeyExists -eq $True)
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    Set-Variable -Name:'Result'  -Value:([Hashtable]a{
      KeyExists   = $RegistryKeyExists
      ValueExists = $RegistryValueExists
      ValueData   = $RegistryValueData
      ValueKind   = $RegistryValueKind
    })
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message: 'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e. listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'Result'
    ))
    Write-Debug -Message: 'Exiting Block:  End'
  }
}
Function Get-RegistryValueData {
  [CmdletBinding(
    , ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding        = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [ValidateSet(
      ,  'String'
      ,  'ExpandString'
      ,  'MultiString'
      ,  'DWord'
      ,  'QWord'
      ,  'Binary'
    )]
    [System.String]
    $Type,
    [Parameter(
      , Mandatory          = $False

    ,  ParameterSetName  =  'Default'
    ,  Position           = 1
    , ValueFromPipeline = $True
  )]
  [ValidateNotNull()]
  [System.String[]]
  $Data,
  [Parameter(
    , Mandatory          = $False
    ,  ParameterSetName  =  'Default'
    ,  Position           = 2
    , ValueFromPipeline = $True
  )]
  [System.Boolean]
  $Hex,
  [Parameter(
    , Mandatory          = $True
    ,  ParameterSetName  =  'Default'
    ,  Position           = 3
    , ValueFromPipeline = $True
  )]
  [System.Management.Automation.PSReference]
  $Result
)
Begin {
  Write-Debug -Message: 'Entering Block:  Begin'
  # Initalize DYNAMIC Variables
  New-Variable -Force -Option:'Private'  -Name:'Result'        -Value:([System.String]::Empty)
  New-Variable -Force -Option:'Private'  -Name: 'ErrorMessage'  -Value:([System.String]::Empty)
  Write-Debug -Message: 'Exiting Block:  Begin'
} Process {
  Write-Debug -Message:'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(
    [System.Array](
      'Result',  'RegistryHive',  'RegistryKey',  'IsFriendlyRegHive',  'IsValidRegHive'
    )
  )
  Set-Variable -Name: 'DataString'         -Value:(ConvertFrom-Array -Value:$Data)
  Set-Variable -Name:'IsDataMultiple'     -Value:([System.Boolean]($Data.Count -gt 1))
  Set-Variable -Name:'IsDataMultiString'  -Value:([System.Boolean]($Type -ine  'MultiString' ))
  Set-Variable -Name:'IsDataNullOrEmpty'  -Value:([System.Boolean](
    [System.String]::IsNullOrEmpty($Data)
  ))
  #
  If ($IsDataMultiString -and $IsDataMultiple -and $IsDataNull) {
    # Load the Appropriate Error Message
    Set-Variable -Name:'ErrorMessage'  -Value:([System.String](
      $localizedData.ParameterValueInvalid -f (
        'ValueData',
        $DataString,
        $Type
      )
    ))
    ThrowError `
      -ErrorCategory: 'InvalidArgument ' `
      -ErrorId: "ArrayNotExpectedForType$($Type)" `
      -ExceptionMessage: $ErrorMessage `
      -ExceptionName: 'System.ArgumentException' `
      -ExceptionObject:$Data
  }

    Switch ($Type) {
      ($PSItem -in @('String',  'ExpandString')) {
        If ($IsDataNullOrEmpty -eq $True) {
          Set-Variable -Name:'Result'  -Value:([System.String]::Empty)
        } Else {
          Set-Variable -Name:'Result'  -Value:([System.String]($Data[0]))
        }
      }
      'MultiString'  {
        If ($IsDataNullOrEmpty -eq $True) {
          Set-Variable -Name:'Result'  -Value:([System.String[]]::new(0))
        } Else {
          Set-Variable -Name:'Result'  -Value:([System.String[]]($Data) )
        }
      }
      'DWord'  {
        If ($IsDataNullOrEmpty -eq $True) {
          Set-Variable -Name:'Result'  -Value:([System.Int32]0)
        } ElseIf($Hex -eq $True) {
          $DataStr
        } Else {
        }
      }
      'QWord'  {
      }
      'Binary'  {
      }
    }
    # It's always desirable to explicitly set the Result object with its desired class as close
    #   to the soft return to ensure the output is predictable and easily traceable.
    # Set-Variable -Name:'Result'  -Value:($null)
    # Do a  'soft'  return by outputting the result to the pipe without using the return function
    #   which would immediately end the function,  this enables us to have the very last
    #   executing item be write-debug giving us a valuable breakpoint & enabling better
    #   debugging functionality and output.
    $Result
    Write-Debug -Message: 'Exiting Block:  Process'
  } End {
    Write-Debug -Message:'Entering Block:  End'
    # Ensure all used variables are both tracked (i.e. Listed) and cleaned up. This isn't
    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name:(@(
      'Result'
    ))
    Write-Debug -Message: 'Exiting Block:  End'
  }
}
Function ConvertFrom-Array {
  [CmdletBinding(
    , ConfirmImpact            =  'None'
    ,  DefaultParameterSetName =  'Default'
    ,  PositionalBinding       = $True
  )]
  Param(
    [Parameter(
      , Mandatory          = $True
      ,  ParameterSetName  =  'Default'
      ,  Position           = 0
      , ValueFromPipeline = $True
    )]
    [AllowEmptyCollection()]
    [ValidateNotNull()]

  [System.String[]]
  $Value
)
Begin {
  Write-Debug -Message:'Entering Block:  Begin'
  # Initalize DYNAMIC Variables
  New-Variable -Force -Option:'Private'  -Name: 'Result'         -Value:( [System.String]::Empty)
  New-Variable -Force -Option:'Private'  -Name: 'ArrayLength'    -Value:([System.Int32]::Empty)
  # StringBuilder must not have the option  'Private',  because the loop method we use
  #   creates a new scope,  and thus it would not be accessible if this was private.
  New-Variable -Force                    -Name: 'StringBuilder'  -Value:([System.Text.StringBuilder]$Null)
  Write-Debug -Message: 'Exiting Block:  Begin'
} Process {
  Write-Debug -Message: 'Entering Block:  Process'
  # Clear all variables immediately upon entering the  'Process'  loop to ensure no stale
  #    values are carried over between piped datasets.
  Clear-Variable -Force -ErrorAction:'SilentlyContinue'  -Name:(
    [System.Array](
      'Result'
    )
  )
  # Calculate the total length (i.e.  character count) of the array,  then account for the
  #   2 additional  ',  '  characters that is added between each array string element.
  Set-Variable -Name:'ArrayLength'  -Value:([System.Int32](
    ($Value  |  Measure-Object -Property:'Length'  -Sum).Sum +
    ([System.Math]::Max($Value.Count,1) * 2)
  ))
  # Initalize the StringBuilder with the correct memory size to preventing costly array
  #   when sizing exceeds default size guesses. Also sets max size to prevent unexpected
  #   behavior and eating up memory..
  Set-Variable -Name:'StringBuilder'  -Value:(
    # System.Text.StringBuilder new(int capacity,  int maxCapacity)
    New-Object -TypeName: 'System.Text.StringBuilder'  -ArgumentList: (
      $ArrayLength,  $ArrayLength
    )
  )
  # As dumb as this looks,  this way of looping is a order of magnitude faster than
  # =  regular for loops,  and its always worth chasing easy performance improvements.
  #   And using [System.Math]::Max,  ensures value is never less than 0.
  0..([System.Math]::Max($value.count-1,0))  |  & {
    Process {
      # System.Text.StringBuilder Append(string value)
      ae = $StringBuilder.Append(  [System.String]('{0},  '  -f $Value[$PSItem])  )
    } End
      # System.Text.StringBuilder Remove(int startIndex,  int length)
    ; $NULL = $StringBuilder.Remove(  ($StringBuilder.Length-2), 2  )
  }
  # It's always desirable to explicitly set the Result object with its desired class as close
  #   to the soft return to ensure the output is predictable and easily traceable.
  Set-Variable -Name:'Result'  -Value:([System.String] (
      $StringBuilder.ToString()
  ))
  # Do a  'soft'  return by outputting the result to the pipe without using the return function
  #   which would immediately end the function,  this enables us to have the very last
  #   executing item be write-debug giving us a valuable breakpoint & enabling better
  #   debugging functionality and output.
  $Result
  Write-Debug -Message:'Exiting Block:  Process'
} End {
  Write-Debug -Message:'Entering Block:  End'
  # Ensure all used variables are both tracked (i.e.  listed) and cleaned up. This isn't

    #   technically required as they will automatically be disposed of when leaving a function,
    #   but I consider this best practice as it forces me to be mindful of all used variables.
    Remove-Variable -Force -ErrorAction: 'SilentlyContinue'  -Name: (@(
       'Result'
    ))
    Write-Debug -Message:'Exiting Block:  End'
  }
}
#endregion ---  [ Active Development ]  -------------------------------------------------------- %#
$InputObject = @'
  {
    "Provider"   :  'Registry',
    "Action"     :  "Test",
    "Ensure"     :  "Present",
    "KeyHive"    :  "HKEY_LOCAL_MACHINE",
    "KeyPath"    :  "\\SOFTWARE\\",
    "KeyName"    :  "7-Zip",
    "ValueName"  :  "Path",
    "ValueData"  :  "Base",
    "ValueKind"  :  "String"
  }
'@ |  ConvertFrom-Json
$Configuration = Start-ProviderSetup -InputObject:$InputObject
$ResourceStart = Get-TargetResource  -InputObject:$Configuration
$ResourceStart
