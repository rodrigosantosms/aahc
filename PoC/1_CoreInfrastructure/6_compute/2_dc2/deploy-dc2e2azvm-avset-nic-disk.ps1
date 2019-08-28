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
    FileName: deploy-dc2e2azvm-avset-nic-disk.ps1
    This script deploys an ARM Template which creates a VM, Availablity Set, vNIC and Managed Data Disk
.NOTES
    AUTHOR(S):
    KEYWORDS: Azure Deploy, PoC, Deployment
#>

# IMPORTANT: Change the value of the following parameters if needed:
#    RgName              <-- This is the Resource Group Name created to host Hub West2 Resources
#    vmName              <-- VM Name
#    vmSize              <-- VM Size (make sure to select an available size supporting Premium Disk)
#    existingVnetName    <-- The Name of your "alias-Recovery-East2-vnet"
#    existingSubnetName  <-- Default is adds-east2-sn
#    stgAcctName         <-- Storage Account Name in the Recovery-East2-rg
#    ARMTemplate  <-- This is the path of the ARM Template will be used to deploy the Hub Resources
#    ARMTemplateParam <-- This is the path of the Parameters file used by the ARM Template to deploy the Hub Resources
#
# Example of how to run this script:
# .\deploy-dc2e2azvm-avset-nic-disk.ps1 -RgName "poc-recovery-rg" -vmName "dc2e2azvm" -vmSize "Standard_D2s_v3" -existingVnetName "recovery-east2-vnet" -existingSubnetName "adds-east2-sn" -stgAcctName "aliasrece2sa01"

### Update the parameters below or provide the values when running the script
Param(
    
    [string] $RgName,
    [string] $vmName,
    [string] $vmSize,
    [string] $existingVnetName,
    [string] $existingSubnetName,
    [string] $stgAcctName ,
    [switch] $UploadArtifacts,
    [string] $ARMTemplate = 'deploy-dc2e2azvm-avset-nic-disk.json',
    [string] $ArtifactStagingDirectory = '.',
    [string] $DeploymentName = 'Deploy-' + (((Get-Date).ToUniversalTime()).ToString('MMddyyyy-HHmm')),
    [switch] $ValidateOnly
)


# Get credentials for VMs
$adminUserName = "localadmin"
$adminCred = Get-Credential -UserName $adminUserName -Message "Enter password for user: $adminUserName"
$adminPassword = $adminCred.GetNetworkCredential().password

# Create parameter hashtable for passing directly to main ARM template
$ARMTemplateParam = @{}
$ARMTemplateParam.Add("vmName",$vmName)
$ARMTemplateParam.Add("vmSize",$vmSize)
$ARMTemplateParam.Add("existingVnetName",$existingVnetName)
$ARMTemplateParam.Add("existingSubnetName",$existingSubnetName)
$ARMTemplateParam.Add("stgAcctName",$stgAcctName)
$ARMTemplateParam.Add("domainName","contosoad.com")
$ARMTemplateParam.Add("adminUserName", $adminUserName)
$ARMTemplateParam.Add("adminPassword", $adminPassword)


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