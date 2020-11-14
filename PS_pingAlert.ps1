# PowerShell script check ping to custom IP-addresses 
# and return email result if error and full report in custom hour of day

# Set report hour                       ## "09" - is example! 
$ticHour = "09"

# Set check timeout                     ## 3600  - is example!
$mySleepSeconds = 3600

# Set target IP array                   ## "8.8.8.8", "1.1.1.1"  - is example!
$targetNamesArray = @("8.8.8.8", "1.1.1.1")

# Set home name
$myHomeName = "..."

# set email credentials
# $UserName = "..."
# $Pass = "..."
# $MyCred = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $UserName, $Pass

# Set email sender
# $myEmailSender = "..."

# Set email receiver
# $myEmailReceiver = "..."

# Set email subject Ok
  $myEmailSubjectOk = "Success ping from "

# Set email subject Alert
  $myEmailSubjectAlert = "Alert ping from "

# Set smtp server
# $mySmtpServer = "..."


# Start

while($true)
{
 # Get current hour 
 $currentHour = Get-Date -f "HH"

 # Match current hour with report time
 if($currentHour -eq $ticHour) 
 {
  # It is time to send report
  $targetResult = " "
  $myFlag = 0
  
  # Test network connections
  foreach($element in $targetNamesArray)
  {
   if(Test-Connection -ComputerName $element -Count 1 -Quiet)
   {
    # Test connection success
    $newTargetResult = "Ping to " + $element + " return success from " + $myHomeName
    $targetResult = $targetResult + ". `r`n " +$newTargetResult
   }
   else
   {
    # Test connection Error
    $myFlag = 1
    $newTargetResult = "Ping to " + $element + " return ERROR from " + $myHomeName
    $targetResult = $targetResult + ". `r`n " + $newTargetResult
   }
  }
  # Prepare report subject
  if($myFlag -eq 0) {$SubjectMessage = $myEmailSubjectOk + $myHomeName} else {$subjectMessage = $myEmailSubjectAlert + $myHomeName}

  # Show report
  if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $SubjectMessage -SmtpServer $mySmtpServer -Credential $MyCred -Body $targetResult} else {Write-Host "Sorry. Email credential not defined"}
  Write-Host $SubjectMessage
  Write-Host $targetResult
 }
 else
 {
 # It is not time to send report
 $targetResult = " "
 $myFlag = 0
 
 # Test network connections
 foreach($element in $targetNamesArray)
 {
  if(Test-Connection -ComputerName $element -Count 1 -Quiet)
  {
   # Test connection success - Do nothing
  }
  else
  {
   # Test connection Error
   $myFlag = 1
   $newTargetResult = "Ping to " + $element + " return ERROR from " + $myHomeName
   $targetResult = $targetResult + $newTargetResult + ". `r`n "
  }
 }
 
 # Prepare report
 if($myFlag -eq 0)
 {
  #  Test connection success - Do nothing
 }
 else
 {
  # Test connection Error - Prepare report
  $subjectMessage = $myEmailSubjectAlert + $myHomeName
  #
  if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $SubjectMessage -SmtpServer $mySmtpServer -Credential $MyCred -Body $targetResult} else {Write-Host "Sorry. Email credential not defined"}
  Write-Host $SubjectMessage
  Write-Host $targetResult
 }
}

Write-Host "tic"
sleep -seconds $mySleepSeconds
}