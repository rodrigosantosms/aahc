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
    Activate Azure with Hybrid Cloud - Main Track - FileName: deploy-recovery-vnet-nsg.ps1
    This script deploys an ARM Template which creates Vnets, Subnets and NSG resources
.NOTES
    AUTHOR(S): Microsoft Enterprise Services
    KEYWORDS: Azure Deploy, PoC, Deployment
#>

# IMPORTANT: Change the value of the following parameters if needed:
#    RgName        <-- This is the Resource Group Name created to host Recovery West2 Resources
#    RgLocation    <-- This is the location of Recovery EastUS2 Resource Group (Default is EastUS2)
# 

### Update the parameters below or provide the values when calling the script
Param(
    
    [string] $RgName = 'poc-recovery-rg',
    [string] $RgLocation = 'eastus2',
    [switch] $UploadArtifacts,
    [string] $ARMTemplate = 'recovery-vnet-nsg.json',
    [string] $ARMTemplateParam = 'recovery-vnet-nsg-parameters.json',
    [string] $ArtifactStagingDirectory = '.',
    [string] [string] $DeploymentName = 'Deploy-' + (((Get-Date).ToUniversalTime()).ToString('MMddyyyy-HHmm')),
    [switch] $ValidateOnly
)

### Do not change lines below
if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzResourceGroupDeployment -Mode Incremental -ResourceGroupName $RgName `
                                                                                  -TemplateFile $ARMTemplate `
                                                                                  -TemplateParameterFile $ARMTemplateParam `
                                                                                  @OptionalParameters)
    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else { 
    New-AzResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $RgName -TemplateFile $ARMTemplate -TemplateParameterFile $ARMTemplateParam -Mode Incremental
                                       
    if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    }
}