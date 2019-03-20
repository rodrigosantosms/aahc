@{
    AllNodes = @(

        @{
            Nodename = "localhost"
            Role = "Primary DC"
            DomainName = "contosoad.com"
            DataDiskNumber = 2
            DataDriveLetter = "F"
            PSDscAllowPlainTextPassword = $true
            RetryCount = 20 
            RetryIntervalSec = 30 
        }
    )
}

