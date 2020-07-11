# Powershell script for sending log error 

# Set credential
# $UserName = "Login"
# $Pass = ConvertTo-SecureString "Password" -AsPlainText -Force
# $myCred = New-Object -TypeName PSCredential -ArgumentList $UserName, $Pass

# Set error template
$myErrTemp = "..."

# Set path to log file
$myPath = "C:\...\"

# Set sender email
$myEmail = "..."

# Set recepient email
$recEmail = "..."

# Set copy email
$copyEmail = "..."

# Set email server IP addres 
$serverEmailIP = "..."

# Set email subject 
$mySubject = "..."

# Start

# Set errors count for alarm 
$myErrCount = 0;

While($true) 
{
$myTestPath = $myPath+"*"
 if(Test-Path $myTestPath)
 { 
      # Find last log
      $myLog = $myPath + (Get-ChildItem -Path $myPath | Sort-Object LastWriteTime -Descending | Select-Object -First 1 ).name

     if (test-Path $myLog) 
     {
          # Calculate errors count matched with template
          $myErrCount = (( Get-Content -Path $myLog) | Select-String -Pattern $myErrTemp ).count

          if ($myErrCount -gt 0)
          {
                # Get last log-record
                $myBody = "Last record:  `r`n "+ (get-Content -Tail 10 $myLog) 

                # Decktop output
                Write-Host "Alert! "  $myBody     
           
                # Send mail
                if($myCred) { Send-MailMessage -From $myEmail -To $recEmail -Cc $copyEmail -Subject $mySubject  -SmtpServer $serverEmailIP -Credential $myCred -Body $myBody -Encoding UTF8 } else { Write-Host "Email credential not defined" }
           }         else  
           { 
                # do nothing 
           }  

      
     }       else  
     { 
          Write-Host Log not found
     }      
 }  else  
 {
     Write-Host Log not found
 }
 
 
 Write-Host One hour tic
 sleep -seconds 3600
}

