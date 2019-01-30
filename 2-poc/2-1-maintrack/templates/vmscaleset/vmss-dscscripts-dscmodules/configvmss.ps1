<#
 	.DISCLAIMER
    This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
    THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED,
    INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  
    We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object
    code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software
    product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the
    Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims
    or lawsuits, including attorneys and fees, that arise or result from the use or distribution of the Sample Code.
    Please note: None of the conditions outlined in the disclaimer above will supersede the terms and conditions contained
    within the Premier Customer Services Description.
#>
Configuration configvmss
{
    [CmdletBinding()]
    param 
    ( 
        [string]$package
    )

    Import-DscResource -ModuleName  xComputerManagement

    Node localhost
    {

        LocalConfigurationManager {
            ConfigurationMode    = 'ApplyAndAutoCorrect'
            RebootNodeIfNeeded   = $true
            ActionAfterReboot    = 'ContinueConfiguration'
            AllowModuleOverwrite = $true
        }

        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature ASP {
            Ensure = "Present"
            Name   = "Web-Asp-Net45"
        }

        WindowsFeature IISManagementTools {
            Ensure    = "Present"
            Name      = "Web-Mgmt-Tools"
            DependsOn = '[WindowsFeature]IIS'
        }

        Script ChangeColor {
            SetScript  = {
                $colors = @("blue","red","green")
                $hostid = hostname
                set-location "C:\packages\"
                Invoke-WebRequest -Uri "$using:package" -OutFile "C:\packages\webcustomize.zip"
                Expand-Archive -LiteralPath "C:\packages\webcustomize.zip" -DestinationPath "C:\packages"
                move-Item "C:\packages\iisstart.htm" "C:\inetpub\wwwroot\iisstart.htm" -force
                move-Item "C:\packages\iisstart.png" "C:\inetpub\wwwroot\iisstart.png" -force
                $color = $colors[$hostid.Substring($hostid.Length-1,1)]
                (Get-Content "C:\inetpub\wwwroot\iisstart.htm").replace('servername=', ('Server Name: ' + $hostid)) | Set-Content "C:\inetpub\wwwroot\iisstart.htm"
                (Get-Content "C:\inetpub\wwwroot\iisstart.htm").replace('blue', $color) | Set-Content "C:\inetpub\wwwroot\iisstart.htm"
                remove-item "C:\packages\webcustomize.zip" -force
            }
            GetScript  = { @{} }
            TestScript = { $false }
            DependsOn  = '[WindowsFeature]IIS'
        }
    }
}