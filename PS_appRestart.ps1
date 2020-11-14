# PowerShell script restart App when it has stopeed 
# or if it has stopped write log. 
# With email alert

# Set report hour                       ## "08" - is example!
$myTicHour = "08"         

# Set check timeout                     ## 3600  - is example!
$mySleepSeconds = 3600

# Set App identificator to monitoring   ## Calculator - is example!
$myApp = "Calculator"     

# Set App path                          ## "C:\Windows\system32\" - is example! 
$myPath = "C:\Windows\system32\"  

# Set App name with extension           ## "calc.exe" - is example! 
$myAppName = "calc.exe"

# Set check log file size flag          ## $false - is example! 
$myFlagCheckLog = $true

# Set App log catalog                   ## "C:\Users\y\Documents\Logs\" - is example! 
$myLogsCatalog = "C:\Users\y\Documents\Logs\"

# Set App log file name                 ## "mylog.log" - is example! 
$myLogName = "mylog.log"

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

# Start log size
$fileSizeOld = 0

# Start current Date
$currentDateOld = (Get-Date -f "yyyy") + (Get-Date -f "MM") + (Get-Date -f "dd")

$fullPath = $myPath+$myAppName

while($true) 
{
 # Get current hour
 $currentHour = Get-Date -f "HH"


 if($myFlagCheckLog)
 {
  # ## Log file size control part:
  # Get current date
  $currentDate = (Get-Date -f "yyyy") + (Get-Date -f "MM") + (Get-Date -f "dd")

  # Check date change and init values
  if($currentDate -ne $currentDateOld)
  {
   $fileSizeOld = 0
   $currentDateOld = (Get-Date -f "yyyy") + (Get-Date -f "MM") + (Get-Date -f "dd")
   # Write-Host Date changed
  } 

  # Get current log file
  # Special case
  $fileName = $myLogsCatalog + $currentDate + "\" + $myLogName
 
  # Check log exists
  if(Test-Path $fileName)
  {
   # Log file present
   # Get log file size
   $fileSize = (Get-Item $fileName).length
  
   # Check log file size change
   if(-Not($fileSize -gt $fileSizeOld))
   {
    # Log file size not grow 
    # Get last string from log
    $lastRecord = Get-Item -Path $fileName | Get-Content -Tail 1

    Write-Host Alert! Log file size not grow. App has stopped. -ForegroundColor Yellow
    # Send email alert
    $myEmailBodyAlert = $myEmailBodyAlert + ". Last log record is: " + $lastRecord
    if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectAlert -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyAlert} else {Write-Host "Sorry. Email credential not defined"}

    # App try restart: 
    Write-Host App try restart
    $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
  
    if($myAppState)
    {
     # App is running. 
     # App stop:
     foreach($appState in $myAppState) { $appState | Stop-Process -Force }
     sleep -seconds 5
     if(!$myAppState.HasExited) 
     { 
      foreach($appState in $myAppState) { $appState.Kill() } 
     }
     sleep -seconds 5
     # App start:
     Invoke-Item $fullPath
     sleep -seconds 5
    }
    else
    {  
     # App has stopped.
     # App start:
     Invoke-Item $fullPath
    }
  
    # App state report:
    $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
    if($myAppState)
    {
     Write-Host App has restarted
     # Send email Ok restarted
     $myEmailBodyOk = $myEmailBodyOk + ". App was restarted! "
     if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectOk -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyOk} else {Write-Host "Sorry. Email credential not defined"}
    }

   }
   else
   {
    # Log file size Ok
    $fileSizeOld = $fileSize
    Write-Host "Log file size Ok" -ForegroundColor Green
   }
  }
  else
  {
   # Log file not find
   Write-Host Alert! Log file not found. App has stopped. -ForegroundColor Yellow
   # Send email alert
   $myEmailBodyAlert = $myEmailBodyAlert + ". Log file not found! "
   if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectAlert -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyAlert} else {Write-Host "Sorry. Email credential not defined"}

   # App try restart: 
   Write-Host App try restart
   $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
  
   if($myAppState)
   {
    # App is running. 
    # App stop:
    foreach($appState in $myAppState) { $appState | Stop-Process -Force }
    sleep -seconds 5
    if(!$myAppState.HasExited) 
    { 
     foreach($appState in $myAppState) { $appState.Kill() } 
    }
    sleep -seconds 5
    # App start:
    Invoke-Item $fullPath
    sleep -seconds 5
   }
   else
   {  
    # App has stopped.
    # App start:
    Invoke-Item $fullPath
   }
  
   # App state report:
   $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
   if($myAppState)
   {
    Write-Host App has restarted
    # Send email Ok restarted
    $myEmailBodyOk = $myEmailBodyOk + ". App was restarted! "
    if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectOk -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyOk} else {Write-Host "Sorry. Email credential not defined"}
   }
  }
 }


 # ## Process control part:
 # Match current hour with report time
 if($currentHour -eq $myTicHour)
 {
   # It is time to send report
   $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
   if($myAppState)
    {
      Write-Host "It is time to send report:"
      Write-Host "App runnig. It's Ok." -ForegroundColor Green
      # Send email Ok
      if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectOk -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyOk} else {Write-Host "Sorry. Email credential not defined"}
    }
  }
  else
  {
   # It is not time to send report
   $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
   if($myAppState)
    {
      # App Ok - Do nothing
      Write-Host "App runnig. It's Ok." -ForegroundColor Green
    }
   else
    {
      # App Stopped
      Write-Host "App has stopped. Error" -ForegroundColor Yellow

      # Send email alert
      if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectAlert -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyAlert} else {Write-Host "Sorry. Email credential not defined"}

      # Restart App
      Write-Host "Let's try to run App"
      ##
      $fullPath = $myPath+$myAppName
      Invoke-Item $fullPath
      
      sleep -seconds 5
      # Check App status and send email
      $myAppState = Get-Process -Name $myApp -ErrorAction SilentlyContinue
      if($myAppState)
      {
      Write-Host "App running. It's Ok" -ForegroundColor Green
      # Send email Ok started
      $myEmailBodyOk = $myEmailBodyOk + ". App was started! "
      if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $myEmailSubjectOk -SmtpServer $mySmtpServer -Credential $MyCred -Body $myEmailBodyOk} else {Write-Host "Sorry. Email credential not defined"}
      }
     }
    }
   Write-Host "tic"
   sleep -seconds $mySleepSeconds
 }

  