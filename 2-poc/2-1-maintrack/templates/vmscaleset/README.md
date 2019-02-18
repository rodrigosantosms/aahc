# Deploy Two Tier Application on Linux and Azure SQL DB

This template deploys a two tier demo application using an existing infrastructural components. When deployed, the resulting resource group will contain a fully working, highly available, and secure .NET Core Web application. 

Before deploying this template, you need to deploy the previous sections of this POC, which will create the following Infrastructure resources required for this template:
    - 1 Resource Group for shared Infra resources, 1 keyvault, 1 secret called adminPassword, KeyVault configured to allow template access
    - 1 Resource Group for Web resources, 1 Vnet + 1 Subnet + 1 NSG for web resources. The NSG should allow ports TCP 80 and 50000 to 50010

After completing the pre-requisites, execute the following steps:

#### Step 1: To start, create a connection with Azure

```bash
az login
```

<br>

#### Step 2: If you have access to multiple Subscriptions, set the subscription you want to use

```bash
az account set --subscription "SubscriptionName or SubscriptionID"
```

<br>

#### Step 3: There are three options to deploy the template

##### Option 1 - Local Computer: Use this option if you want to download the files azuredeploy.json and azuredeploy-parameters.json to your local computer. You will need to open and change the values for the parameters in the azuredeploy-parameters.json file

```bash
az group deployment create --resource-group poc-hub-rg --template-file azuredeploy.json --parameters @azuredeploy-parameters.json
```

<br>

##### Option 2 - Remote: Use this option if you want to use the online templates passing all the required parameters inline. All parameters below are REQUIRED

```bash
az group deployment create --resource-group poc-web-rg \
--template-uri https://raw.githubusercontent.com/rodrigosantosms/aahc/master/2-poc/2-1-maintrack/templates/vmscaleset/azuredeploy.json \
--parameters vmssName=web-vmss instanceCount=2 vmSize=Standard_D1_v2 \
AzureSqlServerName=pocwebvmsssql001 WebSiteDnsName=aahcwebvmss001 \
existingVnetName=web-west2-vnet existingSubnetName=web-sn \
adminUsername=localadmin vaultResourceGroupName=poc-hub-rg vaultName=aahckv mySecret=adminPassword
```

<br>

##### Option 3 - Cloud Shell: Use this option if you prefer your CloudShell Storage Account. First you will need to download the file azuredeploy.json to your local computer, then using Azure Storage Explorer, Upload it to your CloudShell StorageAccount

az group deployment create --resource-group poc-web-rg \
--template-uri https://StorageAccountName.blob.core.windows.net/BlobContainerName/azuredeploy.json \
--parameters vmssName=web-vmss instanceCount=2 vmSize=Standard_D1_v2 \
AzureSqlServerName=pocwebvmsssql001 WebSiteDnsName=aahcwebvmss001 \
existingVnetName=web-west2-vnet existingSubnetName=web-sn \
adminUsername=localadmin vaultResourceGroupName=poc-hub-rg vaultName=aahckv mySecret=adminPassword

<br>

Once that completed, the application can be access on the Azure public IP address or or public DNS name.

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https://raw.githubusercontent.com/rodrigosantosms/aahc/master/2-poc/2-1-maintrack/templates/vmscaleset/azuredeploy.json" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
<a href="http://armviz.io/#/?load=https://raw.githubusercontent.com/rodrigosantosms/aahc/master/2-poc/2-1-maintrack/templates/vmscaleset/azuredeploy.json" target="_blank">
<img src="http://armviz.io/visualizebutton.png"/>
</a>

The application architecture is similar to this:

![](./images/architecture.png)
