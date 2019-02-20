Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Scope AllUsers,User,Session -confirm:$false
Set-PowerCLIConfiguration -Scope User -ParticipateInCEIP $false -confirm:$false

# Connect to VCenter
$username=<VCenter username>
$password=<VCenter password>
Connect-VIServer -Server $VIServer -Protocol https -User $username -Password $password

$csv = $args[0]
$vms = Import-CSV $csv
#$vms = Import-CSV "C:\NewVMs.csv"
$netmask = "XX.XX.XX.XX"
$custSysprep = Get-OSCustomizationSpec -Name <OSCustomization Name> -Server $VIServer
$gateway = "XX.XX.XX.XX"
$taskTab = @{}
$network = @{}

# Create all the VMs specified in $newVmList
foreach ($vm in $vms){
	sleep 3
        Get-VM -Name $vm.name | Out-Null
        if($?)
        {
                $check_vm = $vm.name
                echo "VM $check_vm already exists, please check"
                exit 1
        }
	$custSysprep `
		| Get-OSCustomizationNicMapping `
		| Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $vm.ip -SubnetMask $netmask  -DefaultGateway $vm.gateway
	$taskTab[(New-VM -vmhost $vm.host -Name $vm.name -OSCustomizationSpec $custSysprep  -Template $vm.Template -Datastore $vm.Datastore -Location $vm.cluster -RunAsync).Id]=$vm.name
	$network.($vm.name)=$vm.network
	$network[$vm.name]
        }
$custSysprep | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode PromptUser -SubnetMask $netmask  -DefaultGateway $gateway

# Start each VM that is completed
$runningTasks = $taskTab.Count
while($runningTasks -gt 0){
Get-Task | % {
	if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
		Get-VM -Name $taskTab[$_.Id] | Get-NetworkAdapter | Set-NetworkAdapter -NetworkName $network[$taskTab[$_.Id]] -Confirm:$false
		Get-VM $taskTab[$_.Id] | Start-VM
		$taskTab.Remove($_.Id)
		$runningTasks--
  }
	elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
		$taskTab.Remove($_.Id)
		$runningTasks--
  }
}
Start-Sleep -Seconds 5
}

# Disconnect VCenter Server
Disconnect-VIServer -Server $VIServer -confirm:$false
