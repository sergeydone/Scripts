# Powershell script  in design - replace files in users catalogs

# Set source directory
[string]$sourceDirectory = "C:\Install\AppCatalog\*"

# Set destination directory
[string]$destinationDirectory = "C:\Users"

# Set destination directory App folder
$NameToFind = "AppCatalog"

# Set local path to save log
$myPath = "C:\Install\Log\"

 Write-Host Start

# Get date
$currentDate = "" + (Get-Date).ToString('yyyy-MM-dd hh:mm')

# Init Log file name
if(Test-Path $myPath)
{
 $myFullPath = $myPath + "AppUpdateLog" + ".txt"

 # Init Log variable
 $LogVar = "";

 # Replace files in Users App directories
 Get-ChildItem $destinationDirectory -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.EndsWith($NameToFind) } |
 ForEach-Object { $destinationDirectory = $_.FullName + "\"; Write-Host "View directory" $destinationDirectory; if(Test-Path($destinationDirectory)) { Copy-Item -Force -Recurse $sourceDirectory -Destination $destinationDirectory; $LogVar = "Updated directory" + $destinationDirectory + "  " + $currentDate + ""; Write-Host $LogVar; $LogVar | out-file -filepath $myFullPath -append -width 200 } 
 else 
  { 
   $LogVar = $destinationDirectory + " : User have no App installed "; $LogVar | out-file -filepath $myFullPath -append -width 200 
  } 
  Write-Host Ended successfully
 }
} else
 {
 Write-Host Update skipped. Sorry but Log file directory not defined
 }
