#Requires -Version 5.0
<#
 	.DISCLAIMER
    This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
    THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
    We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object
    code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software
    product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the
    Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims
    or lawsuits, including attorneys� fees, that arise or result from the use or distribution of the Sample Code.
    Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained
    within the Premier Customer Services Description.
#>
<#
.SYNOPSIS
    deploy-recovery-east2-vnet-nsg.ps1 - Script that creates Vnets, Subnets and NSGs
.DESCRIPTION
	This script deploys an ARM Template which creates Vnets, Subnets and NSG resources
.NOTES
    AUTHOR(S): Microsoft Enterprise Services
    KEYWORDS: PoC, Deployment
#>

#
# Activate Azure with Hybrid Cloud - Main Track - Vnet, Subnet and NSG deployment
#
# IMPORTANT: Change the value of the following parameters if needed:
#    WebRgName        <-- This is the Resource Group Name created to host Web West2 Resources
#    WebRgLocation    <-- This is the location of Web West2 Resource Group (Default is WestUs2)
#    WebVNetTemplate  <-- This is the path of the ARM Template will be used to deploy the Web Resources
#    WebVNetTempParam <-- This is the path of the Parameters file used by the ARM Template to deploy the Web Resources
# 


Param(
    
    [string] $WebRgName = 'poc-web-rg',
    [string] $WebRgLocation = 'WestUS2',
    [switch] $UploadArtifacts,
    [string] $WebVNetTemplate = 'C:\Azure\aahc\2-poc\2-1-maintrack\templates\networking\web-vnet-nsg.json',
    [string] $WebVNetTemplateParameters = 'C:\Azure\aahc\2-poc\2-1-maintrack\templates\networking\web-vnet-nsg-parameters.json',
    [string] $ArtifactStagingDirectory = '.',
    [string] [string] $DeploymentName = 'Deploy-' + (((Get-Date).ToUniversalTime()).ToString('MMddyyyy-HHmm')),
    [switch] $ValidateOnly
)


### Create or update the resource group using the specified template file and template parameters file
if ($ValidateOnly) {
    $ErrorMessages = Format-ValidationOutput (Test-AzureRmResourceGroupDeployment -ResourceGroupName $WebRgName `
                                                                                  -TemplateFile $WebVNetTemplate `
                                                                                  -TemplateParameterFile $WebVNetTemplateParameters `
                                                                                  @OptionalParameters)
    if ($ErrorMessages) {
        Write-Output '', 'Validation returned the following errors:', @($ErrorMessages), '', 'Template is invalid.'
    }
    else {
        Write-Output '', 'Template is valid.'
    }
}
else { 
    New-AzureRmResourceGroupDeployment -Name $DeploymentName -ResourceGroupName $WebRgName -TemplateFile $WebVNetTemplate -TemplateParameterFile $WebVNetTemplateParameters 
                                       
    if ($ErrorMessages) {
        Write-Output '', 'Template deployment returned the following errors:', @(@($ErrorMessages) | ForEach-Object { $_.Exception.Message.TrimEnd("`r`n") })
    }
}

