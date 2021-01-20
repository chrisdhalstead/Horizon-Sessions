
<#
.SYNOPSIS
Samples Scripts Using the VMware Horizon API via PowerCLI
	
.NOTES
  Version:        1.0
  Author:         Chris Halstead - chalstead@vmware.com
  Creation Date:  7/18/2019
  Purpose/Change: Initial script development
 #>

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
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
    
    $script:hvServer = Connect-HVServer -Server $horizonserver -User $username -Password $UnsecurePassword -Domain $domain
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
      
      $sresult = $qSRv.QueryService_Query($hvServices,$query)
              
    }
    
    catch {
      Write-Host "An error occurred when getting sessions $_"
     break 
    }
    
  if ($sresult.results.count -eq 0)
   {
    write-host "No Sessions"
    break   
    
    }

#Add Local CSV for Session Data
Add-Content -Path C:\Sessions.csv  -Value '"Username","Pool Name","Machine Name","Client Name","Client Type","Client Version","Client IP","Session Type","Session State","Location","Idle Duration"'
  
write-host "Results will be logged to: "$sLogPath"\"$sLogName
write-host "There are" $sresult.results.Count "total sessions"

#$sresult.Results | Format-table -AutoSize -Property @{Name = 'Username'; Expression = {$_.namesdata.username}},@{Name = 'Pool Name'; Expression = {$_.namesdata.desktopname}},@{Name = 'Machine Name'; Expression = {$_.namesdata.machineorrdsservername}}`
#,@{Name = 'Client Name'; Expression = {$_.namesdata.clientname}},@{Name = 'Client Type'; Expression = {$_.namesdata.clienttype}},@{Name = 'Client Version'; Expression = {$_.namesdata.clientversion}},@{Name = 'Client IP'; Expression = {$_.namesdata.clientaddress}}`
#,@{Name = 'Session Type'; Expression = {$_.sessiondata.sessiontype}},@{Name = 'Session State'; Expression = {$_.sessiondata.sessionstate}},@{Name = 'Location'; Expression = {$_.namesdata.securityGatewayLocation}},@{Name = 'Idle Duration'; Expression = {$_.sessiondata.IdleDuration}}
 
$sresult.Results | Select-Object -Property @{Name = 'Username'; Expression = {$_.namesdata.username}},@{Name = 'Pool Name'; Expression = {$_.namesdata.desktopname}},@{Name = 'Machine Name'; Expression = {$_.namesdata.machineorrdsservername}}`
,@{Name = 'Client Name'; Expression = {$_.namesdata.clientname}},@{Name = 'Client Type'; Expression = {$_.namesdata.clienttype}},@{Name = 'Client Version'; Expression = {$_.namesdata.clientversion}},@{Name = 'Client IP'; Expression = {$_.namesdata.clientaddress}}`
,@{Name = 'Session Type'; Expression = {$_.sessiondata.sessiontype}},@{Name = 'Session State'; Expression = {$_.sessiondata.sessionstate}},@{Name = 'Location'; Expression = {$_.namesdata.securityGatewayLocation}},@{Name = 'Idle Duration'; Expression = {$_.sessiondata.IdleDuration}} | Export-Csv -path c:\sesspom.csv -NoTypeInformation

  
} 


function Show-Menu
  {
    param (
          [string]$Title = 'VMware Horizon API Menu'
          )
       Clear-Host
       Write-Host "================ $Title ================"
             
       Write-Host "Press '1' to Login to Horizon"
       Write-Host "Press '2' for a List of Sessions"
       Write-Host "Press '3' for a List of Applications"
       Write-Host "Press '4' for a List of Machines"
       Write-Host "Press '5' to Reboot a Desktop"
       Write-Host "Press '6' for a List of Desktop Pools"
       Write-Host "Press '7' for Connection Server Info"
       Write-Host "Press '8' for Usage Info"
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
    
    '3' {
       
         GetApplications
      
    }

    '4' {
       
     GetMachines
   
 }


 '5' {
       
  RebootDT

}

'6' {
       
        GetDtPools
     
   }
   '7' {
       
    GetCSInfo
 
}
'8' {
       
  GetUsage

}

    }
    pause
 }
 
 until ($selection -eq 'q')


