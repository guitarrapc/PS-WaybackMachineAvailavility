ReadMe
=============================

# what is this?
PowerShell function to obtain Wayback Machine Availavility from Wayback Machine APIs

# API details

Refer following API information.

> [Wayback Machine APIs](http://archive.org/help/wayback_api.php)

# Usage

This Cmdlet supports API for "Wayback Availability JSON API".

You can use ```url``` and ```timestamp``` parameter.

## ```url``` parameter

Input available url to check whether "Wayback Machine" is availeble.

```PowerShell
Get-WaybackMachineAvailavility -url "http://tech.guitarrapc.com"
```

you can use pipeline to pass multiple url at once.

```Powershell
"http://tech.guitarrapc.com","http://neue.cc" | Get-WaybackMachineAvailavility
```

If invalid url was passed, then API returns null.

## ```timestamp``` parameter

Additional options which may be specified are ```timestamp```

Timestamp is the timestamp to look up in Wayback. If not specified, the most recenty available capture in Wayback is returned.

Make sure ```timestamp``` format as 1-14 digits of 'yyyyMMddHHmmss' or 'yyyy' or 'yyyyMM' or 'yyyyMMdd' or else.('2006' will tring to obtain closed to 2006)

```PowerShell
Get-WaybackMachineAvailavility -url http://neue.cc -timestamp 20060101 -Verbose
```

this may result closed to ```timestamp``` date "20060101".

