Function Get-Spn {

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
    $tbl_spn.Clear()

    # Query for SQL Server SPNs
    $objDomain = ([ADSI]'').distinguishedName
    $objDomainPath  = [ADSI]''
    $objSearcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher -ArgumentList $objDomainPath
    $objSearcher.PageSize = 1000
    $objSearcher.Filter = '(&(servicePrincipalName=*))'
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

            # Parse last logon
            if ($_.properties.lastlogon)
            {
                $LastLogon = [datetime]::FromFileTime([string]$_.properties.lastlogon).ToString('g')
            }else{
                $LastLogon = ''
            }

            # Add results to table if its an SQL Service 
            
                $null = $tbl_spn.Rows.Add(
                [string]$SamAccountName,
                [string]$Description,
                $LastLogon,
                [string]$SpnServer,
                [string]$SpnService,   
                [string]$Spn    
                )           
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
