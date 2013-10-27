workflow Get-WaybackMachineAvailavilityParallel
{
<#
.Synopsis
   Parallel Get serachUri status of Wayback Machine.

.DESCRIPTION
   This simple API for Wayback is a test to see if a given url is archived and currenlty accessible in the Wayback Machine.
   This API is useful for providing a 404 or other error handler which checks Wayback to see if it has an archived copy ready to display. The API can be used as follows

.EXAMPLE
   # check status for specific uri
   Get-WaybackMachineAvailavilityParallel -url "http://tech.guitarrapc.com"

.EXAMPLE
   # check status for specific uri and show as table view (default list view)
   Get-WaybackMachineAvailavilityParallel -url "http://tech.guitarrapc.com" | Format-Table -AutoSize

.EXAMPLE
   # check status for specific uri, showing what is the function status with Verbose switch.
   Get-WaybackMachineAvailavilityParallel -url "http://tech.guitarrapc.com"

.EXAMPLE
   # check status for specific date you want. API will returns as close date as you input in timestamp.
   Get-WaybackMachineAvailavilityParallel -url http://neue.cc -timestamp 20060101 -Verbose

.EXAMPLE
   # check status for multiple uri
   Get-WaybackMachineAvailavilityParallel -urls "http://tech.guitarrapc.com","http://neue.cc" 

.EXAMPLE
   # check status for multiple uri and show as table view (default list view)
   Get-WaybackMachineAvailavilityParallel -urls "http://tech.guitarrapc.com","http://neue.cc" -Verbose | Format-Table -AutoSize

.EXAMPLE
   # check status for multiple uri recieved from pipeline, showing result for only available uri was returned.
   Get-WaybackMachineAvailavilityParallel -urls "http://exampleasdfasdfadfa.com","http://tech.guitarrapc.com" | where available -ne $null
#>
    [CmdletBinding()]
    Param
    (
        # Input an uri you want to search.
        [Parameter(
            Mandatory = 1,
            Position=0)]
        [string[]]
        $urls,


        # Input timestamp to obtain closed date you want. Make sure as format 'yyyyMMddHHmmss' or 'yyyy' or 'yyyyMM' or 'yyyyMMdd' or else.('2006' will tring to obtain closed to 2006)
        [Parameter(
            Mandatory = 0,
            Position=1)]
        [string]
        $timestamp
    )

    # base settings for query
    $baseUri = "http://archive.org/wayback/available"
    $baseQuery = "?url="
    $timestampQuery = "&timestamp="


    # start process
    foreach -parallel ($url in $urls)
    {
        Write-Debug ("start creating command for '{0}'" -f $url)
        
        # build query
        $query = "$baseQuery{0}" -f ($url | where {$_})

        # validate timestamp parameter for query
        if (-not [string]::IsNullOrWhiteSpace($timestamp))
        {
            $trimTimestampQuery = $timestamp | where {$_}
            $query = "$query{0}{1}" -f $timestampQuery, $trimTimestampQuery
        }

        # build query uri
        $queryUri = (@($baseUri,$query) | where { $_ } | % { ([string]$_).Trim('/') } | where { $_ } ) -join '/'

        # invoke request
        Write-Verbose -Message ("trying to collect availability of Wayback Time machine for uri '{0}' from API '{1}'" -f $url, $baseUri)
        Write-Verbose -Message ("Whole query string '{0}'" -f $queryUri)

        # using Invoke-RestMethod
        $task = Invoke-RestMethod -Method Get -Uri $queryUri -UserAgent ("PowerShell {0}" -f $PSVersionTable.PSVersion)

        # get reuslt
        $result =  $task.archived_snapshots.closest

        # create sorted hashtable to create object
        $obj = [ordered]@{
            available = $result.available
            status = $result.status
            timestamp = $result.timestamp
            url = $result.url
            queryInformation = @{
                url = $url
                queryUri = $queryUri
            }
        }

        # create PSObject to output
        $output = New-Object -TypeName PSObject -Property $obj
        $output
    }
}