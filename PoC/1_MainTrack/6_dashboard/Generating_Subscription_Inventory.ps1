# Log in to Azure
Login-AzAccount

# Select the Subscription
$subid = "Enter-YourSubscription-ID"

# Export Location - do not add "\" at the end
$Folder = "C:\azure\powershell\inventory"

# Connect to AAD (use this in case you have access to multiple AAD tenants)
#Connect-AzureAD -TenantId "Tenant-ID" 

##########################################################################################################################
# Do not change the variables and code below #

$AzSub = Get-AzSubscription -SubscriptionID $subid
Set-AzContext -SubscriptionId $subid 

# Creating folder
Set-Location $Folder

# 1 - List Resources
function Get-AzInvResources() {
    $obj = New-Object -TypeName PSCustomObject
    ForEach ($rec in Get-AzResource ) {
        $obj | Add-Member -MemberType NoteProperty -Name Name -Value $rec.Name -Force
        $obj | Add-Member -MemberType NoteProperty -Name ResourceType -Value $rec.ResourceType -Force
        $obj | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $rec.ResourceGroupName -Force
        $obj | Add-Member -MemberType NoteProperty -Name Location -Value $rec.Location -Force
        $obj | Add-Member -MemberType NoteProperty -Name SubscriptionID -Value ($AzSub).Id -Force
        $obj | Add-Member -MemberType NoteProperty -Name SubscriptionName -Value ($AzSub).Name -Force
        if ($null -eq $rec.Tags) {
            $obj | Add-Member -MemberType NoteProperty -Name Tags -Value " " -Force
        }
        else {
            $RecTag = ([string]($rec.Tags.GetEnumerator() | ForEach-Object { "$($_.Key):$($_.Value)," }))
            $obj | Add-Member -MemberType NoteProperty -Name Tags -Value $RecTag -Force
        }
        $obj
    }
}

# 2 - List Role Assignment
function Get-AzInvRoleAssignment () {
    $RBAC = Get-AzRoleAssignment -scope "/subscriptions/$subid"
    foreach ($perm in $RBAC) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $perm.DisplayName -Force
        $obj | Add-Member -MemberType NoteProperty -Name SignInName -Value $perm.SignInName -Force
        $obj | Add-Member -MemberType NoteProperty -Name ObjectID -Value $perm.ObjectID -Force
        $obj | Add-Member -MemberType NoteProperty -Name ObjectType -Value $perm.ObjectType -Force
        $obj | Add-Member -MemberType NoteProperty -Name Scope -Value $perm.Scope -Force
        $obj | Add-Member -MemberType NoteProperty -Name RoleDefinition -Value $perm.roledefinitionname -Force
        $obj | Add-Member -MemberType NoteProperty -Name CanDelegate -Value $perm.CanDelegate -Force
        $obj | Add-Member -MemberType NoteProperty -Name SubscriptionName -Value ($AzSub).Name -Force
        $obj
    }
}

# 3 - List Role Definition
function Get-AzInvRoleDefinition () {
    foreach ($RoleDef in Get-AzRoleDefinition) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name Name -Value $RoleDef.Name -Force
        $obj | Add-Member -MemberType NoteProperty -Name ID -Value $RoleDef.ID -Force
        $obj | Add-Member -MemberType NoteProperty -Name IsCustom -Value $RoleDef.IsCustom -Force
        $obj | Add-Member -MemberType NoteProperty -Name Description -Value $RoleDef.Description -Force
        $obj | Add-Member -MemberType NoteProperty -Name Actions -Value ([string]($RoleDef.actions | ForEach-Object { "$($_)," })) -Force
        $obj
    }
}

# 4 - List AAD Application
function Get-AzInvADApplication () {
    foreach ($AADapp in Get-AzADApplication) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $AADapp.DisplayName -Force
        $obj | Add-Member -MemberType NoteProperty -Name ObjectId -Value $AADapp.ObjectId -Force
        $obj | Add-Member -MemberType NoteProperty -Name IdentifierUris -Value ([string]($AADapp.IdentifierUris | ForEach-Object { "$($_)," })) -Force
        $obj | Add-Member -MemberType NoteProperty -Name HomePage -Value $AADapp.HomePage -Force
        $obj | Add-Member -MemberType NoteProperty -Name Type -Value $AADapp.Type -Force
        $obj | Add-Member -MemberType NoteProperty -Name ApplicationId -Value $AADapp.ApplicationId -Force
        $obj | Add-Member -MemberType NoteProperty -Name AvailableToOtherTenants -Value $AADapp.AvailableToOtherTenants -Force
        $obj | Add-Member -MemberType NoteProperty -Name AppPermissions -Value $AADapp.AppPermissions -Force
        $obj | Add-Member -MemberType NoteProperty -Name ReplyUrls -Value ([string]($AADapp.ReplyUrls | ForEach-Object { "$($_)," })) -Force
        $obj
    }
}


# 5 - List AAD Groups
function Get-AzInvADGroup () {
    foreach ($AADgroup in Get-AzADGroup) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $AADgroup.DisplayName -Force
        $obj | Add-Member -MemberType NoteProperty -Name Id -Value $AADgroup.Id -Force
        $obj | Add-Member -MemberType NoteProperty -Name SecurityEnabled -Value $AADgroup.SecurityEnabled -Force
        $obj | Add-Member -MemberType NoteProperty -Name Type -Value $AADgroup.Type -Force
        $obj | Add-Member -MemberType NoteProperty -Name GroupMembersUserPrincipalNames -Value ([string](Get-AzADGroupMember -GroupObjectId $AADgroup.ID | ForEach-Object { "$($_.UserPrincipalName)," })) -Force
        $obj | Add-Member -MemberType NoteProperty -Name GroupMembers -Value ([string](Get-AzADGroupMember -GroupObjectId $AADgroup.ID | ForEach-Object { "$($_.UserPrincipalName):$($_.DisplayName):$($_.Id):$($_.Type)," })) -Force
        $obj
    }
}


# 6 - List AAD Service Principals
function Get-AzInvADServicePrincipal () {
    foreach ($AADsvcprin in Get-AzADServicePrincipal) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $AADsvcprin.DisplayName -Force
        $obj | Add-Member -MemberType NoteProperty -Name Id -Value $AADsvcprin.Id -Force
        $obj | Add-Member -MemberType NoteProperty -Name ApplicationId -Value $AADsvcprin.ApplicationId -Force
        $obj | Add-Member -MemberType NoteProperty -Name Type -Value $AADsvcprin.Type -Force
        $obj | Add-Member -MemberType NoteProperty -Name ServicePrincipalNames -Value ([string]($AADsvcprin.ServicePrincipalNames | ForEach-Object { "$($_)," })) -Force
        $obj | Add-Member -MemberType NoteProperty -Name SpCredential -Value (Get-AzADSpCredential -ObjectId $AADsvcprin.Id ) -Force
        $obj
    }
}


# 7 - List AAD Users
function Get-AzInvADUser () {
    foreach ($AADuser in Get-AzADUser) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name DisplayName -Value $AADuser.DisplayName -Force
        $obj | Add-Member -MemberType NoteProperty -Name Id -Value $AADuser.Id -Force
        $obj | Add-Member -MemberType NoteProperty -Name UserPrincipalName -Value $AADuser.UserPrincipalName -Force
        $obj | Add-Member -MemberType NoteProperty -Name Type -Value $AADuser.Type -Force
        $obj
    }
}


# 8 - Key Vault Certificates
function Get-InvAzureKeyVaultCertificate () {
    foreach ($keyvault in Get-AzKeyVault) {
        foreach ($KvCertificate in Get-AzureKeyVaultCertificate -VaultName $keyvault.VaultName) {
            $obj = New-Object -TypeName PSCustomObject
            $obj | Add-Member -MemberType NoteProperty -Name Name -Value $KvCertificate.Name -Force
            $obj | Add-Member -MemberType NoteProperty -Name VaultName -Value $KvCertificate.VaultName -Force
            $obj | Add-Member -MemberType NoteProperty -Name Enabled -Value $KvCertificate.Enabled -Force
            $obj | Add-Member -MemberType NoteProperty -Name Id -Value $KvCertificate.Id -Force
            $obj | Add-Member -MemberType NoteProperty -Name Version -Value $KvCertificate.Version -Force
            $obj | Add-Member -MemberType NoteProperty -Name Expires -Value $KvCertificate.Expires -Force
            $obj | Add-Member -MemberType NoteProperty -Name NotBefore -Value $KvCertificate.NotBefore -Force
            $obj | Add-Member -MemberType NoteProperty -Name Created -Value $KvCertificate.Created -Force
            $obj | Add-Member -MemberType NoteProperty -Name Updated -Value $KvCertificate.Updated -Force
            $obj | Add-Member -MemberType NoteProperty -Name Tags -Value $KvCertificate.Tags -Force
            $obj
        }
    }
}

# 9 - Key Vault Access Policies
function Get-InvAzKeyVault () {
    $vaults = Get-AzKeyVault
    $keyvault = Get-AzKeyVault -VaultName tempkvcontoso

    foreach ($keyvault in Get-AzKeyVault -VaultName $vaults.VaultName) {
        $obj = New-Object -TypeName PSCustomObject
        $obj | Add-Member -MemberType NoteProperty -Name VaultName -Value $keyvault.VaultName -Force
        $obj | Add-Member -MemberType NoteProperty -Name ResourceGroupName -Value $keyvault.ResourceGroupName -Force
        $obj | Add-Member -MemberType NoteProperty -Name Location -Value $keyvault.Location -Force
        $obj | Add-Member -MemberType NoteProperty -Name ResourceID -Value $keyvault.ResourceID -Force
        $obj | Add-Member -MemberType NoteProperty -Name VaultURI -Value $keyvault.VaultURI -Force
        $obj | Add-Member -MemberType NoteProperty -Name SKU -Value $keyvault.SKU -Force
        $obj | Add-Member -MemberType NoteProperty -Name AccessPolicies  -Value ([string]($keyvault.AccessPolicies | ForEach-Object { "$($_)," })) -Force
        $obj
    }
}

# Exporting CSVs
Get-AzInvResources | Export-Csv -Path "$Folder\1-AzInvResources.csv"          -NoTypeInformation  -Force
Get-AzInvRoleAssignment | Export-Csv -Path "$Folder\2-AzInvRoleAssignment.csv"     -NoTypeInformation  -Force
Get-AzInvRoleDefinition | Export-Csv -Path "$Folder\3-AzInvRoleDefinition.csv"     -NoTypeInformation  -Force
Get-AzInvADApplication | Export-Csv -Path "$Folder\4-AzInvADApplication.csv"      -NoTypeInformation  -Force
Get-AzInvADGroup | Export-Csv -Path "$Folder\5-AzInvADGroup.csv"            -NoTypeInformation  -Force
Get-AzInvADServicePrincipal | Export-Csv -Path "$Folder\6-AzInvADServicePrincipal.csv" -NoTypeInformation  -Force
Get-AzInvADUser | Export-Csv -Path "$Folder\7-AzInvADUser.csv"             -NoTypeInformation  -Force
Get-InvAzureKeyVaultCertificate | Export-Csv -Path "$Folder\8-InvKeyVaultCertificate.csv"       -NoTypeInformation  -Force
Get-InvAzKeyVault | Export-Csv -Path "$Folder\9-InvKeyVault.csv"                  -NoTypeInformation  -Force

Disable-AzContextAutosave