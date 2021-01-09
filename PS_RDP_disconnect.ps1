# Powershell script for inactive terminal sessions disconnection - in design

# Set username whitelist
$myWhiteList = @("username1", "username2")

# Set inteval, sec
$tic = 3600

# Set email credentials
# $UserName = "..."
# $Pass = "..."
# $MyCred = New-Object -Typename System.Management.Automation.PSCredential -ArgumentList $UserName, $Pass

# Set email sender
# $myEmailSender = "..."

# Set email receiver
# $myEmailReceiver = "..."

# Set email subject 
# $myEmailSubjectOk = "Inactive terminal users have disconnected: "

# Set smtp server
# $mySmtpServer = "..."

# Write-Host start

while($true) 
{

 # esults initialization
 $resultData = ""

 # Temporary arrays initialization (clear) 
 $users = @()
 $sessions = @()

 # Get all sessions
 $output = (quser | select -Skip 1).substring(1)

 foreach ($line in $output)
 {
  # Filter disconnected sessions
  if($line -match 'disc')
  {
   # Get user names
   $userName = ($line -split '\s+')[0]

   # Whitelist Flag initialization
   $myFlag = 0

   # Check whitelist
   foreach ($element in $myWhiteList)
   { 
    if($element -eq $userName) { $myFlag = 1 }
   }

   # If whitelist Flag hasn't set
   if($myFlag -eq 0)
   {
    $users += $userName
    $sessions += ($line -split '\s+')[1]
   }
   else 
   {
    # Whitelist Flag has set
    # Do nothing
   }
  }
 }

 # Show user names to disconnect
 foreach ($name in $users)
 {
  $resultData += (", "+ $name)
 }

 # Check result
 if($resultData -ne "") 
 {
  # Session id to disconnect
  foreach ($ses in $sessions)
  {
   logoff $ses
  }

  # Show and send report
  if($MyCred) {Send-MailMessage -From $myEmailSender -To $myEmailReceiver -Subject $SubjectMessage -SmtpServer $mySmtpServer -Credential $MyCred -Body $resultData -Encoding UTF8} else {Write-Host "Sorry. Email credential not defined"}
 }
 
 Write-Host "timer tic"
 Sleep -seconds $tic
}




