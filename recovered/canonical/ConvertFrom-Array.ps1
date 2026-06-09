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
