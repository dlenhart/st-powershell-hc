<#

.SYNOPSIS
This is a simple Powershell script to ping a list of websites or servers from a text file.

.DESCRIPTION
The script performs a test-connection on a list of websites/servers to get an up or down status.
-optional failure email, uncomment function in script...

.EXAMPLE
./hc_ping.ps1

.NOTES
Author:  Drew D. Lenhart
File Name:  hc_ping.ps1

.LINK
http://github.com/snowytech/st-powershell-hc

#>

$ServerListFile = "server-ping.txt"   
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue
$LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LogFile = "logs\hc_ping-results.html"
 
##EMAIL function##

function sendMail($datestamp){
    ##Use GMAILs free smtp services, must use port 587
    $smtpServer = "smtp.gmail.com" 
    $srvPort = 587
    $smtpFrom = "youremail@gmail.com" 
    $smtpTo = "to email address" 
    $messageSubject = "Ping Script Results - $datestamp"
    $message = New-Object System.Net.Mail.MailMessage $smtpfrom, $smtpto 
    $message.Subject = $messageSubject 
    $message.IsBodyHTML = $true 
    $message.Body = "<html><head></head><body>" 
    $message.Body += Get-Content $LogFile
    $message.Body += "</body></html>"
    $smtp = New-Object Net.Mail.SmtpClient($smtpServer, $srvPort)
    $smtp.EnableSsl = $true
    $smtp.Credentials = New-Object System.Net.NetworkCredential("gmail username without @gmail.com", "gmail password") 
    ##Send message
    $smtp.Send($message)
}


##### Script Starts Here ######  
$Outputreport = ""
$Outputreport = "<h3>Ping Stats: $LogTime</h3>"
$Outputreport += "<table><tr style='background-color: grey; color: white'><td>Hostname</td><td>Status</td></tr>"
$count = 0
$failCount = 0

foreach ($Server in $ServerList) {

    if (test-Connection -ComputerName $Server -Count 2 -Quiet ) {

        echo "($Server): is pingable"
        $Outputreport += "<tr><td>$Server</td><td style='background-color: green; color: white'>ONLINE</td></tr>"
    }
    else
    { 
        echo "$Server seems dead Jim" 
        $Outputreport += "<tr><td>$Server</td><td style='background-color: red'>OFFLINE</td></tr>"
        $failCount = $failCount + 1
    }
        
    $count = $count + 1
        
}

$Outputreport += "</table>"
$Outputreport += "<br />Server count: $count"
echo "Server count: " $count
$Outputreport | out-file $LogFile

if ($failCount -ge 1) {
    #Uncomment below to email failures using sendMail ( uses gmail )
    #sendMail "$LogTime"
}