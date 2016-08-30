<#

.SYNOPSIS
A simple Powershell script to gather http status code from a list of websites.

.DESCRIPTION
The script performs Invoke-WebRequest to gather HTTP status code and measures response in milliseconds.

.EXAMPLE
.\hc_status_code.ps1

.NOTES
200 = good,  0,500 = bad
Inspired by:  https://gallery.technet.microsoft.com/scriptcenter/Powershell-Script-for-13a551b3

Update 'server-status.txt' with a list of websites to monitor.

Author:  Drew D. Lenhart
File Name:  hc_ping.ps1

.LINK
http://github.com/snowytech/st-powershell-hc

#>

$ServerListFile = "server-status.txt"   
$ServerList = Get-Content $ServerListFile -ErrorAction SilentlyContinue
$LogTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$LogFile = "logs\hc_status_code-results.html"
$Result = @()

$Outputreport = "<html><title>Website Status Codes</title><body><h2>Website Status Code Check</h2>
    <table border=1 cellpadding=0 cellspacing=0><tr align=center>
    <td><b>URL</b></td>
    <td><b>StatusCode</b></td>
    <td><b>StatusDescription</B></td>
    <td><B>Response (MS)</b></td>
    <td><B>TimeTaken</b></td</tr>"

foreach($Uri in $ServerList) { 
    $time = try{ 
        $request = $null 
        ## Request the URI, and measure how long the response took. 
        $result1 = Measure-Command { $request = Invoke-WebRequest -Uri $uri } 
        $result1.TotalMilliseconds 
    }
    catch 
    { 
        $request = $_.Exception.Response 
        echo $_.Exception.Response
    }

    $Uri = $uri; 
    $StatusCode = [int] $request.StatusCode 
    $StatusDescription = $request.StatusDescription 
    $TimeTaken =  $LogTime;
    
    if($StatusCode -ne "200") 
        {
            $MilliSecondsResp =  0
            $StatusDescription = "BAD"
            $Outputreport += "<tr bgcolor=red>" 
        } 
        else 
        {
            $MilliSecondsResp =  $result1.TotalMilliseconds
            $Outputreport += "<tr>" 
        } 
        echo $Uri
        echo $StatusCode
        echo $StatusDescription
        
        $Outputreport += "<td>$($Uri)</td><td align=center>$($StatusCode)</td>
        <td align=center>$($StatusDescription)</td>
        <td align=center>$($MilliSecondsResp)</td>
        <td align=center>$($TimeTaken)</td></tr>" 

} 

$Outputreport += "</table></body></html>" 
 
$Outputreport | out-file $LogFile 

Exit