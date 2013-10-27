function Get-WaybackMachineAvailavility
{
<#
.Synopsis
   Get serachUri status of Wayback Machine had been available

.DESCRIPTION
   This simple API for Wayback is a test to see if a given url is archived and currenlty accessible in the Wayback Machine.
   This API is useful for providing a 404 or other error handler which checks Wayback to see if it has an archived copy ready to display. The API can be used as follows

.EXAMPLE
   # check status for specific uri
   Get-WaybackMachineAvailavility -url "http://tech.guitarrapc.com"

.EXAMPLE
   # check status for specific uri and show as table view (default list view)
   Get-WaybackMachineAvailavility -url "http://tech.guitarrapc.com" | Format-Table -AutoSize

.EXAMPLE
   # check status for specific uri, showing what is the function status with Verbose switch.
   Get-WaybackMachineAvailavility -url "http://tech.guitarrapc.com"

.EXAMPLE
   # check status for specific date you want. API will returns as close date as you input in timestamp.
   Get-WaybackMachineAvailavility -url http://neue.cc -timestamp 20060101 -Verbose

.EXAMPLE
   # check status for multiple uri recieved from pipeline
   "http://tech.guitarrapc.com","http://neue.cc" | Get-WaybackMachineAvailavility

.EXAMPLE
   # check status for multiple uri recieved from pipeline and show as table view (default list view)
   "http://tech.guitarrapc.com","http://neue.cc" | Get-WaybackMachineAvailavility -Verbose | Format-Table -AutoSize

.EXAMPLE
   # check status for multiple uri recieved from pipeline, showing result for only available uri was returned.
   "http://exampleasdfasdfadfa.com","http://tech.guitarrapc.com" | Get-WaybackMachineAvailavility | where available -ne $null
#>
    [CmdletBinding()]
    Param
    (
        # Input an uri you want to search.
        [Parameter(
            Mandatory = 1,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            Position=0)]
        [string]
        $url,


        # Input timestamp to obtain closed date you want. Make sure as format 1-14 digits of 'yyyyMMddHHmmss' or 'yyyy' or 'yyyyMM' or 'yyyyMMdd' or else.('2006' will tring to obtain closed to 2006)
        [Parameter(
            Mandatory = 0,
            Position=1)]
        [string]
        $timestamp
    )

    Begin
    {
        # base settings for query
        $private:baseUri = "http://archive.org/wayback/available"
        $private:baseQuery = "?url="
        $private:timestampQuery = "&timestamp="
        $private:executeCount = 0
    }
    Process
    {
        # build query
        $executeCount++
        $private:trimBaseQuery = $url | where {$_}
        $private:query = $baseQuery + $trimBaseQuery

            # validate timestamp parameter for query
            if (-not [string]::IsNullOrWhiteSpace($PSBoundParameters.timestamp))
            {
                $private:trimTimestampQuery = $PSBoundParameters.timestamp | where {$_}
                $private:query = $query + $timestampQuery + $trimTimestampQuery
            }

        # build query uri
        $private:queryUri = (@($baseUri,$query) | where { $_ } | % { ([string]$_).Trim('/') } | where { $_ } ) -join '/'

        # invoke webrequest
        Write-Verbose ("trying to collect availability of Wayback Time machine for uri '{0}' from API '{1}'" -f $url, $baseUri)
        Write-Verbose ("Whole query string '{0}'" -f $queryUri)
        $private:apiAnswer = Invoke-WebRequest -Uri $queryUri -UserAgent ("PowerShell {0}" -f $PSVersionTable.PSVersion)
        $result = ($apiAnswer.Content | ConvertFrom-Json).archived_snapshots.closest

        # create sorted hashtable to create object
        $obj = [ordered]@{
            executeCount = $executeCount
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
        New-Object -TypeName PSObject -Property $obj

    }
}