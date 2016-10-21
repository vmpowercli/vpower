<#  
.SYNOPSIS  
	A powercli script to Enable Powershell, add a disk and provision as D Drive inside the VM    
.DESCRIPTION  
	This sciprt helps adding additional disk to VMs and provision it as D Drive. 

 Build engineer, Deployment Date and Functionality fields of annotation are automatically popultated.

.NOTES  
    Author         : Prashanth Mandalapu
    Prerequisite   : PowerShell V2 over Vista and upper.
#>

$computername = get-content d:\Power_cli\Servera.txt

##Local VM Admin Credentials

$password = Get-content  D:\power_cli\PASSWORD.txt
$key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
$SecPassword = ConvertTo-SecureString -String $password -Key $key
$username = "$VM\admin$VM"
$GC = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $SecPassword

##VC Credentials 

#$User = "tfayd\~206428265"
#$File = "d:\Power_cli\VMPass"
#$Credential=New-Object -TypeName System.Management.Automation.PSCredential `
# -ArgumentList $User, (Get-Content $File | ConvertTo-SecureString)

$password = Get-content  D:\power_cli\VMPass.txt
$key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
$SecPassword = ConvertTo-SecureString -String $password -Key $key
$username = "tfayd\~206428265"
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $username, $SecPassword


#$UserName = Read-Host "Enter User Name:" 
#$Password = Read-Host -AsSecureString "Enter Your Password:" 
#$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName , $Password 
#$Service = Get-WmiObject -Class Win32_Service -ComputerName $ComputerName -Credential $Credential -Filter "Name='IISADMIN'" 
#$Service


$Dsize= 50

foreach ($VM in $computername) { 

#get-WmiObject win32_logicaldisk -Computer $VM -credential $cred

#E:\Script\Enable-RemotePSRemoting.ps1 $VM

write-host “Working on VM $VM initiated”  -foreground green

Add-PSSnapin VMware.VimAutomation.Core
connect-viserver USHIFWP00043.tfayd.com -WarningAction SilentlyContinue -ea SilentlyContinue -credential $Credential

New-HardDisk -VM $VM -CapacityGB $Dsize -StorageFormat thin -Confirm:$false


Start-Sleep -s 2

$script = '$Disk = Get-Disk 1;
            $Disk | Initialize-Disk -PartitionStyle MBR;
            New-Partition -DiskNumber $Disk.Number -AssignDriveLetter -UseMaximumSize; 
            Format-Volume -DriveLetter D -FileSystem NTFS -confirm:$false;
            $D="_D$";
            Format-Volume -DriveLetter D -NewFileSystemLabel "$env:computername$D" -confirm:$false'

             
Invoke-VMScript -VM $VM -GuestCredential $GC -scripttext $script -ScriptType powershell

disconnect-viserver USHIFWP00043.tfayd.com -Force -WarningAction SilentlyContinue -confirm:$false


###########################################################################
##Invoke-Command using Domain Credentials. 

#Invoke-Command -ComputerName $VM -ScriptBlock  {

#"rescan" | diskpart
#$Disk = Get-Disk 1
#$Disk | Initialize-Disk -PartitionStyle MBR
#New-Partition -DiskNumber $Disk.Number -AssignDriveLetter -UseMaximumSize
#Format-Volume -DriveLetter D -FileSystem NTFS -confirm:$false
#$D1="_D$"
#Format-Volume -DriveLetter D -NewFileSystemLabel "$env:computername$D1" -confirm:$false
#}  -credential $Credential

#Invoke-Command -ComputerName $VM -FilePath E:\Script\failover.ps1 -credential $Credential
#Invoke-Command -ComputerName $VM {get-WmiObject win32_logicaldisk} -credential $cr

#}
###################################################################################################

}