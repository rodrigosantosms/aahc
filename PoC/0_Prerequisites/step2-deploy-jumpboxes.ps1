#Requires -Version 5.0
<#
.DISCLAIMER
    MIT License - Copyright (c) Microsoft Corporation. All rights reserved.
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
    FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
    IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
    SOFTWARE
.DESCRIPTION
    FileName: step2-deploy-jumpboxes.ps1
    This script deploys an ARM Template which creates a VM, vNIC, Managed Data Disk and sets the auto shutdown policy.
    The VMs will use the following image by default - you can update that in the related ARM Template:
        "publisher": "MicrosoftWindowsDesktop","offer": "Windows-10","sku": "19h1-pro","version": "latest"
.NOTES
    AUTHOR(S): 
    KEYWORDS: Azure Deploy, PoC, Deployment
#>

# IMPORTANT: Change the value of the following parameters if needed:
#    RgName              <-- This is the Resource Group for your Emulated-On-Premises resources
#    vmSize              <-- Select a VM Size available in YOUR Azure Subscription. Make sure you have vCPUs enough already enabled, if not, open an Azure Support Ticket requesting more CPUs
#    vmCount             <-- Number of Jumpbox VMs to be created
#    vmShutDownTime      <-- Military time you want the machine to be shutdown
#    vmShutDownTimeZone  <-- Timezone name for the machine to be shutdown, this needs to be the text based name.
#
# Example of how to run this script:
# .\step2-deploy-jumpboxes.ps1 -RgName "emulated-on-premises-rg" -vmSize "Standard_D2s_v3" -vmCount 12 -vmShutDownTime "1830" -vmShutDownTimeZone "Pacific Standard Time"

### Update the parameters below or provide the values when running the script
Param(
    
    [string] $RgName = 'emulated-on-premises-rg',
    [string] $vmSize = 'Standard_D2s_v3',
    [int] $vmCount = 12,
    [switch] $ValidateOnly,
    [string] $vmShutDownTime = '1830',
    [string] $vmShutDownTimeZone = 'Pacific Standard Time'
)

# Get credentials for VMs
$adminUserName = "localadmin"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName"
$adminPassword = $adminCred.GetNetworkCredential().password

# Define variables (do not change)
$vmName = 'jumpbox'
$existingVnetName = 'emulated-on-premises-vnet'
$existingSubnetName = 'jumpbox-sn'
$ARMTemplate = 'step2-deploy-jumpboxes.json'
$DeploymentName = 'Deploy-' + (((Get-Date).ToUniversalTime()).ToString('MMddyyyy-HHmm'))

# Create parameter hashtable for passing directly to main ARM template
$ARMTemplateParam = @{ }
$ARMTemplateParam.Add("adminUserName", $adminUserName)
$ARMTemplateParam.Add("adminPassword", $adminPassword)
$ARMTemplateParam.Add("vmName", $vmName)
$ARMTemplateParam.Add("vmCount", $vmCount)
$ARMTemplateParam.Add("vmSize", $vmSize)
$ARMTemplateParam.Add("existingVnetName", $existingVnetName)
$ARMTemplateParam.Add("existingSubnetName", $existingSubnetName)
$ARMTemplateParam.Add("vmShutDownTime", $vmShutDownTime)
$ARMTemplateParam.Add("vmShutDownTimeZone", $vmShutDownTimeZone)


if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -Mode Incremental -ResourceGroupName $RgName `
            -TemplateFile $ARMTemplate `
            -TemplateParameterObject $ARMTemplateParam `
            @OptionalParameters)
    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else { 
    New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $RgName -TemplateFile $ARMTemplate -TemplateParameterObject  $ARMTemplateParam -Mode Incremental
                                       
    if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    }
}