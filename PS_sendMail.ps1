$UserName = "Login"
$Pass = ConvertTo-SecureString "Password" -AsPlainText -Force
$MyCred = New-Object -TypeName PSCredential -ArgumentList $UserName, $Pass
if($MyCred) {Send-MailMessage -From EMAIL1 -To EMAIL2 -Cc EMAIL3 -Subject "SUBJECT" -SmtpServer 1.1.1.1 -Credential $MyCred -Body "LETTER CONTENT"} else (Write-Host "Email credential not defined"}