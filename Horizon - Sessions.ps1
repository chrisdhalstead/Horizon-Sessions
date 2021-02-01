
<#
.SYNOPSIS
Script to output Horizon Session data to .CSV via PowerCLI
	
.NOTES
  Version:        1.1
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  1/20/2021
  Purpose/Change: Updated for > 1,000 sessions and added Session Start Time

  Thanks to Wouter Kursten for the guidance on returning more than 1,000 objects in this article:
  https://www.retouw.nl/2017/12/12/get-hvmachine-only-finds-1000-desktops/

  Also thanks to feedback on code.vmware.com I added Session Start Time
  
 #>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$script:mydocs = [environment]::getfolderpath('mydocuments')
$script:date = Get-Date -Format d 
$script:date = $script:date -replace "/","_"
#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function LogintoHorizon {

#Capture Login Information

$script:HorizonServer = Read-Host -Prompt 'Enter the Horizon Server Name'
$Username = Read-Host -Prompt 'Enter the Username'
$Password = Read-Host -Prompt 'Enter the Password' -AsSecureString
$domain = read-host -Prompt 'Enter the Horizon Domain'

#Convert Password
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
$UnsecurePassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

try {
    
    $script:hvServer = Connect-HVServer -Server $horizonserver -User $username -Password $UnsecurePassword -Domain $domain -Force
    $script:hvServices = $hvServer.ExtensionData
    }

catch {
  Write-Host "An error occurred when logging on $_"
  break
}

write-host "Successfully Logged In"

} 

Function GetSessions {
    
    if ([string]::IsNullOrEmpty($hvServer))
    {
       write-host "You are not logged into Horizon"
        break   
       
    }
       
    try {

      $query = New-Object "Vmware.Hv.QueryDefinition"

      $query.queryEntityType = 'SessionLocalSummaryView'
      
      $qSrv = New-Object "Vmware.Hv.QueryServiceService"

      #Support over 1000 sessions
      $offset = 0
      $qdef = New-Object VMware.Hv.QueryDefinition
      $qdef.limit= 1000
      $qdef.maxpagesize = 1000
      $qdef.queryEntityType = 'SessionLocalSummaryView'

      $ssessionoutput=@()
      
      do{
        $qdef.startingoffset = $offset
        $sResult = $qsrv.queryservice_create($hvServices, $qdef)
            if (($sResult.results).count -eq 1000)
                {
                $maxresults = 1
                }
            else 
                {
                $maxresults = 0
                }

        $offset+=1000
        $ssessionoutput+=$sResult
        }
      until ($maxresults -eq 0)
                     
    }
    
    catch {
      Write-Host "An error occurred when getting sessions $_"
     break 
    }
    
  if ($ssessionoutput.results.count -eq 0)
   {
    write-host "No Sessions"
    break   
    
    }

#Add Local CSV for Session Data
Add-Content -Path $script:mydocs\Sessions_$script:date.csv  -Value '"Session Start Time","Display Protocol","Username","Pool Name","Machine Name","Client Name","Client Type","Client Version","Client IP","Session Type","Session State","Location","Idle Duration"'
  
write-host "There are" $sresult.results.Count "total sessions"

#Write results to table
$ssessionoutput.Results | Format-table -AutoSize -Property @{Name = 'Session Start Time'; Expression = {$_.sessiondata.startTime}},@{Name = 'Display Protocol'; Expression = {$_.sessiondata.SessionProtocol}},@{Name = 'Username'; Expression = {$_.namesdata.username}},@{Name = 'Pool Name'; Expression = {$_.namesdata.desktopname}},@{Name = 'Machine Name'; Expression = {$_.namesdata.machineorrdsservername}}`
,@{Name = 'Client Name'; Expression = {$_.namesdata.clientname}},@{Name = 'Client Type'; Expression = {$_.namesdata.clienttype}},@{Name = 'Client Version'; Expression = {$_.namesdata.clientversion}},@{Name = 'Client IP'; Expression = {$_.namesdata.clientaddress}}`
,@{Name = 'Session Type'; Expression = {$_.sessiondata.sessiontype}},@{Name = 'Session State'; Expression = {$_.sessiondata.sessionstate}},@{Name = 'Location'; Expression = {$_.namesdata.securityGatewayLocation}},@{Name = 'Idle Duration'; Expression = {$_.sessiondata.IdleDuration}}

#Write results to .CSV file
$ssessionoutput.Results | Select-Object -Property @{Name = 'Session Start Time'; Expression = {$_.sessiondata.startTime}},@{Name = 'Display Protocol'; Expression = {$_.sessiondata.SessionProtocol}},@{Name = 'Username'; Expression = {$_.namesdata.username}},@{Name = 'Pool Name'; Expression = {$_.namesdata.desktopname}},@{Name = 'Machine Name'; Expression = {$_.namesdata.machineorrdsservername}}`
,@{Name = 'Client Name'; Expression = {$_.namesdata.clientname}},@{Name = 'Client Type'; Expression = {$_.namesdata.clienttype}},@{Name = 'Client Version'; Expression = {$_.namesdata.clientversion}},@{Name = 'Client IP'; Expression = {$_.namesdata.clientaddress}}`
,@{Name = 'Session Type'; Expression = {$_.sessiondata.sessiontype}},@{Name = 'Session State'; Expression = {$_.sessiondata.sessionstate}},@{Name = 'Location'; Expression = {$_.namesdata.securityGatewayLocation}},@{Name = 'Idle Duration'; Expression = {$_.sessiondata.IdleDuration}} | Export-Csv -path $script:mydocs\Sessions_$script:date.csv -NoTypeInformation

write-host "Horizon session data written to: $script:mydocs\Sessions_$script:date.csv"

} 

function Show-Menu
  {
    param (
          [string]$Title = 'VMware Horizon PowerCLI Menu'
          )
       Clear-Host
       Write-Host "================ $Title ================"
             
       Write-Host "Press '1' to Login to Horizon"
       Write-Host "Press '2' to Export Sessions to a .CSV"
       Write-Host "Press 'Q' to quit."
         }

do
 {
    Show-Menu
    $selection = Read-Host "Please make a selection"
    switch ($selection)
    {
    
    '1' {  

         LogintoHorizon
    } 
    
    '2' {
   
         GetSessions

    }
    

}
    pause
}
 
 until ($selection -eq 'q')


