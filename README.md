# Horizon-Sessions
Export VMware Horizon Session Data into .CSV

This script will export Horizon Session data into a .CSV file in My Documents Folder.

***<u>There is no support for this tool - it is provided as-is</u>***

Please provide any feedback directly to me - my contact information: 

Chris Halstead - Staff Architect, VMware  
Email: chalstead@vmware.com  
Twitter: @chrisdhalstead  <br />

Thanks to Wouter Kursten for the feedback on supporting over 1,000 sessions.  <br/>

The code to support that is based off of his post here:  https://www.retouw.nl/2017/12/12/get-hvmachine-only-finds-1000-desktops/ <br/>

 This script requires Horizon 7 PowerCLI - https://blogs.vmware.com/euc/2020/01/vmware-horizon-7-powercli.html <br/>

Updated January 22, 2021<br />

------

### Script Overview

This is a PowerShell script that uses PowerCLI and the View-API to query Horizon sessions.  The session are written to a table in the script and also to a .CSV file that can be opened in Excel or a similar spreadsheet tool.

- The .csv file is written to the My Documents folder of the user running the script.  The file format is: **Sessions_Month_Date_Year.csv**

### Script Usage

1. Run `Horizon - Sessions.ps1` 


   ![Menu](https://github.com/chrisdhalstead/horizon-sessions/blob/master/Images/sessionmenu.PNG)

   #### Login to Horizon Connection Server



   ![Login](https://github.com/chrisdhalstead/horizon-sessions/blob/master/Images/Login.PNG)
