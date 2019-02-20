# Vspere-VM-provisioning-automation

## Overview

This script will provide some idea for you to make some automation on VShpere

## Prerequisites

1. VCenter version above 6.0
2. Powershell running environment, you can install powershell on Linux to use command "pwsh" or just use windows powershell.
3. PowerCLI module,use Powershell cmd to execute "Install-Module VMware.PowerCLI -Scope CurrentUser" to install it.
4. You need a VM inventory file with CSV format, you can accord example file to add your VM by yourself.

Notice: It's best to install latest version of powershell.

## Try it out
Excute create_new_vm.ps1 <your VM inventory>.csv

## License
[BSD-2 License](LICENSE.txt)
