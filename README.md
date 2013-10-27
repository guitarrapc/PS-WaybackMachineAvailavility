ReadMe
=============================

#### what is this?
PowerShell function to obtain Wayback Machine Availavility from Wayback Machine APIs

#### API details

Refer following API information.

> [Wayback Machine APIs](http://archive.org/help/wayback_api.php)

#### Usage

This Cmdlet supports API for "Wayback Availability JSON API".

You can use ```urls``` and ```timestamp``` parameter.


Abount ```Cmdlet```
=============================

## Summary

Here's chart for easy understanding.

|Cmdlet|pipeline input|mode|
|----|----|----|
|Get-WaybackMachineAvailavility|O|Synchronous|
|Get-WaybackMachineAvailavilityAsync|X|Aynchronous|
|Get-WaybackMachineAvailavilityPrallel|X|Parallel|

#### Synchronous Cmdlet

You can use ```Get-WaybackMachineAvailavility```.

This supports pipeline input, but synchronous cmdlet may prefer for only small number of urls. (single or less then 5)


#### Asynchronous Cmdlet

You can use ```Get-WaybackMachineAvailavilityAsync```.

This doesn't supports pipeline input, but Asynchronous execute for each url. This prefer for large number of urls. (more than 10)

#### Parallel Cmdlet

You can use ```Get-WaybackMachineAvailavilityParallel```.

This doesn't supports pipeline input, but Parallel execute for each url. This prefer for medium number of urls. (less than 10)


About ```Parameters```
=============================

All cmdlet supports same parameters.

#### ```urls``` parameter

Input available urls to check whether "Wayback Machine" is availeble.
multiple urls will be operate for each url inside cmdlet.

```PowerShell
# Synchronous invokation
Get-WaybackMachineAvailavility -urls "http://tech.guitarrapc.com","http://neue.cc"

# Asynchronous invokation
Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc"

# Parallel invokation
Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc"
```

You can use pipeline to pass multiple url at once for ```Get-WaybackMachineAvailavility```.
However ```Get-WaybackMachineAvailavilityAsync``` and ```Get-WaybackMachineAvailavilityParallel``` not supporting pipeling input.

```Powershell
# Synchronous pipeline invokation
"http://tech.guitarrapc.com","http://neue.cc" | Get-WaybackMachineAvailavility
```

If invalid url was passed, then API returns null.

#### ```timestamp``` parameter

Additional options which may be specified are ```timestamp```

Timestamp is the timestamp to look up in Wayback. If not specified, the most recenty available capture in Wayback is returned.

Make sure ```timestamp``` format as 1-14 digits of 'yyyyMMddHHmmss' or 'yyyy' or 'yyyyMM' or 'yyyyMMdd' or else.('2006' will tring to obtain closed to 2006)

```PowerShell
# Synchronous invokation with 20060101
Get-WaybackMachineAvailavility -url http://neue.cc -timestamp 20060101

# Asynchronous invokation
Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc" -timestamp 20060101

# Parallel invokation
Get-WaybackMachineAvailavilityAsync -urls "http://tech.guitarrapc.com","http://neue.cc" -timestamp 20060101
```

this may result closed to ```timestamp``` date "20060101".

#### common parameter

You can use Common parameters like ``Verbose```, defined by ```[CmdletBinding()]