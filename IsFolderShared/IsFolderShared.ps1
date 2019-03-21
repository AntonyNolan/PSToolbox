Function ADMTIsFolderShared {
<#
.SYNOPSIS
<Overview of script>
#requires -version 2


.DESCRIPTION
<Brief description of script>

.PARAMETER <Parameter_Name>
<Brief description of parameter input required. Repeat this attribute if required>

.INPUTS
<Inputs if any, otherwise state None>

.OUTPUTS
<Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

.NOTES
Version:        1.0
Author:         <Name>
Creation Date:  <Date>
Purpose/Change: Initial script development

.EXAMPLE
<Example goes here. Repeat this attribute for more than one example>
#>

[CmdletBinding()]
    param (
        [Parameter(
            ValueFromPipeLine,
            ValueFromPipelineByPropertyName,
            Mandatory
        )]
        [alias("FullName")]
        [String[]]$Path
    )

Process {
   foreach ($Folder in $Path) {
       $WMIFolderPath = $Folder -replace '\\','\\'
       [PSCustomObject] @{
           "FolderPath" = $Folder
           "IsShared" = if (Get-CimInstance -Query "SELECT * FROM Win32_Share WHERE Path='$WMIFolderPath'") { $true } else { $false }
       }
   }
}
}