# PowerShell script restart Service when it has stopped 
# With email alert

# Set report hour                       ## "08" - is example!
$ticHour = "08"

# Set check timeout                     ## 3600  - is example!
$mySleepSeconds = 60

# Set service name to monitoring        ## "W32Time"  - is example!
$myService = "W32Time"

# set email credentials
# $UserName = "..."
# $Pass = "..."
# $MyCred = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $UserName, $Pass

# Set email sender
# $myEmailSender = "..."

# Set email receiver
# $myEmailReceiver = "..."

# Set email subject Ok
# $myEmailSubjectOk = "..."

# Set email subject Alert
# $myEmailSubjectAlert = "..."

# Set email body Ok
# $myEmailBodyOk = "..."

# Set emai body alert
# $myEmailBodyAlert = "..."

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
   $myServiceStatus = Get-Service -Name $myService
   if($myServiceStatus.Status -eq 'Running')
    {
      Write-Host "Service runnig. It's Ok." -ForegroundColor Green
      if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectOk -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyOk} else {Write-Host "Sorry. Email credential not defined"}
    }
  }
  else
  {
   # It is not time to send report
   $myServiceStatus = Get-Service -Name $myService
   if($myServiceStatus.Status -eq 'Running')
    {
      # Service Ok - Do nothing
      Write-Host "Service runnig. It's Ok." -ForegroundColor Green
    }
    else
    {
      # Service Stopped
      Write-Host "Service has stopped. Error" -ForegroundColor Yellow

      # Send email alert
      if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectAlert -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyAlert} else {Write-Host "Sorry. Email credential not defined"}

      # Run service
      Write-Host "Let's try to run service"
      Start-Service $myService

      # Check service status and send email
      $myServiceStatus = Get-Service -Name $myService
      if($myServiceStatus.Status -eq 'Running')
      {
      Write-Host "Service running. It's Ok" -ForegroundColor Green
      if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectOk -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyOk} else {Write-Host "Sorry. Email credential not defined"}
      }
     }
    }
   Write-Host tic
   sleep -seconds $mySleepSeconds
 }

  