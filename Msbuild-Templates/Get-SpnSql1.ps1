Function Get-SpnList {

    [CmdletBinding()]
    Param()

    # Data table for output
    $tbl_spn = New-Object -TypeName System.Data.DataTable
    $null = $tbl_spn.Columns.Add('Samaccountname')
    $null = $tbl_spn.Columns.Add('Description')
    $null = $tbl_spn.Columns.Add('LastLogon')
    $null = $tbl_spn.Columns.Add('SPNServer')
    $null = $tbl_spn.Columns.Add('SPNService')    
    $null = $tbl_spn.Columns.Add('SPN')  
    $null = $tbl_spn.Columns.Add('SQLInstance')                 
    $tbl_spn.Clear()

    # Query for SQL Server SPNs
    $objDomain = ([ADSI]'').distinguishedName
    $objDomainPath  = [ADSI]''
    $objSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ArgumentList $objDomainPath
    $objSearcher.PageSize = 1000
    $objSearcher.Filter = '(&(servicePrincipalName=*MSSQLSvc*))'
    $objSearcher.SearchScope = 'Subtree'
    $objSearcher.FindAll() |
    ForEach-Object {

        $SamAccountName = $_.properties.samaccountname
        $Description = $_.properties.description

        foreach ($item in $($_.properties.serviceprincipalname)){

            # Parse SPNs
            $SpnServer = $item.split('/')[1].split(':')[0].split(' ')[0]
            $SpnService = $item.split('/')[0]
            $Spn = $item

            $Instance = $Spn.split('/')[1].split(':')[1]

            # Check if the instance is a number and use the relevent delim
            $Value = 0
            if([int32]::TryParse($Instance,[ref]$Value))
            {
                $SQLInstance = $Spn -replace ':', ','
            }else{
                $SQLInstance = $Spn -replace ':', '\'
            }

            $SQLInstance = $SQLInstance -replace 'MSSQLSvc/', ''

            # Parse last logon
            if ($_.properties.lastlogon)
            {
                $LastLogon = [datetime]::FromFileTime([string]$_.properties.lastlogon).ToString('g')
            }else{
                $LastLogon = ''
            }

            # Add results to table if its an SQL Service 
            If ($SpnService -like "*SQL*"){
                $null = $tbl_spn.Rows.Add(
                [string]$SamAccountName,
                [string]$Description,
                $LastLogon,
                [string]$SpnServer,
                [string]$SpnService,   
                [string]$Spn, 
                [string]$SQLInstance           
                )
            }
        }
    }

    $tbl_spn
    $count = $tbl_spn.Rows.Count
    Write-Verbose "Found $count SQL Server SPNs"
}

Get-SpnList -Verbose

# $x = Get-SpnList -Verbose
# $x | Out-GridView
# $x | Export-Csv -NoTypeInformation output.csv

