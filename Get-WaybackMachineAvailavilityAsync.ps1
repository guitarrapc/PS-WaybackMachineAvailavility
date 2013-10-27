function Get-WaybackMachineAvailavilityAsync
{
<#
.Synopsis
   Asynchronous Get serachUri status of Wayback Machine.

.DESCRIPTION
   This simple API for Wayback is a test to see if a given url is archived and currenlty accessible in the Wayback Machine.
   This API is useful for providing a 404 or other error handler which checks Wayback to see if it has an archived copy ready to display. The API can be used as follows

.EXAMPLE
   # check status for specific uri
   Get-WaybackMachineAvailavilityAsync -url "http://tech.guitarrapc.com"

.EXAMPLE
   # check status for specific uri and show as table view (default list view)
   Get-WaybackMachineAvailavilityAsync -url "http://tech.guitarrapc.com" | Format-Table -AutoSize

.EXAMPLE
   # check status for specific uri, showing what is the function status with Verbose switch.
   Get-WaybackMachineAvailavilityAsync -url "http://tech.guitarrapc.com" -Verbose

.EXAMPLE
   # check status for specific date you want. API will returns as close date as you input in timestamp.
   Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc","http://gitHub.com","http://google.com" -timestamp 200601 -Verbose

.EXAMPLE
   # check status for multiple uri
   Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc"

.EXAMPLE
   # check status for multiple uri recieved from pipeline and show as table view (default list view)
   Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc"

.EXAMPLE
   # check status for multiple uri recieved from pipeline, showing result for only available uri was returned.
   Get-WaybackMachineAvailavilityAsync -urls "http://exampleasdfasdfadfa.com","http://tech.guitarrapc.com" | where available -ne $null
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

    try
    {
        # change ErrorActionPreference
        Write-Debug "set continue with error as http client requires dispose when method done."
        $originalErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Continue"

        # create Runspace
        Write-Debug ("creating runspace for powershell")
        $sessionstate = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        $minPoolSize = $maxPoolSize = 50 # 50 runspaces
        $runspacePool = [runspacefactory]::CreateRunspacePool($minPoolSize, $maxPoolSize,  $sessionstate, $Host) # create Runspace Pool
        $runspacePool.ApartmentState = "STA" # only STA mode supports
        $runspacePool.Open() # open pool


        # start process
        foreach ($url in $urls)
        {
            Write-Debug ("start creating command for '{0}'" -f $url)
            $command = {

                $url = $args[0]
                $timestamp = $args[1]
                $VerbosePreference = $args[2]
                
                # base settings for query
                $private:baseUri = "http://archive.org/wayback/available"
                $private:baseQuery = "?url="
                $private:timestampQuery = "&timestamp="

                # build query
                $private:query = "{0}{1}" -f $baseQuery, $url | where {$_}

                    # validate timestamp parameter for query
                    if (-not [string]::IsNullOrWhiteSpace($timestamp))
                    {
                        $private:trimTimestampQuery = $timestamp | where {$_}
                        $private:query = "$query{0}{1}" -f $timestampQuery, $trimTimestampQuery
                    }

                # build query uri
                $private:queryUri = (@($baseUri,$query) | where { $_ } | % { ([string]$_).Trim('/') } | where { $_ } ) -join '/'

                # Load Assembly to use HttpClient
                try
                {
                    Add-Type -AssemblyName System.Net.Http
                }
                catch
                {
                }

                # new HttpClient
                $httpClient = New-Object -TypeName System.Net.Http.HttpClient
                $httpClient.BaseAddress = $private:baseUri

                # invoke http client request
                Write-Verbose ("trying to collect availability of Wayback Time machine for uri '{0}' from API '{1}'" -f $url, $baseUri)
                Write-Verbose ("Whole query string '{0}'" -f $queryUri)
                $private:task = $httpClient.GetStringAsync($queryUri)
                $task.wait()
                return $task
            }

            # Verbose settings for Async Command inside
            Write-Debug "set VerbosePreference inside Asynchronous execution"
            if ($PSBoundParameters.Verbose.IsPresent)
            {
                $verbose = "continue"
            }
            else
            {
                $verbose = $VerbosePreference
            }

            # Main Invokation
            Write-Debug "start asynchronous invokation"
            $powershell = [PowerShell]::Create().AddScript($command).AddArgument($url).AddArgument($timestamp).AddArgument($verbose)
            $powershell.RunspacePool = $runspacePool
            [array]$RunspaceCollection += New-Object -TypeName PSObject -Property @{
                Runspace = $powershell.BeginInvoke();
                powershell = $powershell
            }
        }


        # check process result
        Write-Debug "check asynchronos execution has done"
        while (($runspaceCollection.RunSpace | sort IsCompleted -Unique).IsCompleted -ne $true)
        {
            sleep -Milliseconds 5
        }

        # get process result and end powershell session
        Write-Debug "obtain process result"
        foreach ($runspace in $runspaceCollection)
        {
            # obtain Asynchronos command result
            $task = $runspace.powershell.EndInvoke($runspace.Runspace)

            # show result
            if ($task.IsCompleted)
            {
                # get reuslt
                $private:result = ($task.Result | ConvertFrom-Json).archived_snapshots.closest
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

            # Dispose pipeline
            $runspace.powershell.Dispose()
        }
    }
    finally
    {
        # Dispose Runspace
        $runspacePool.Dispose()
    }
}