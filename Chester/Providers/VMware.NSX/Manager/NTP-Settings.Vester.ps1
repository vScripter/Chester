
<#
    Chester Test File
    -----------------
    Provider: VMware.NSX
    Scope   : Manager
#>

# Test title (e.g. 'DNS Servers')
#$Title = 'DNS Servers'
$Title = 'NSX Manager NTP Settings'

# Test description: How the module explains this value to the user
#$Description = 'DNS address(es) for the host to query against'
$Description = 'NTP address(es) for the NSX Manager to use for Time Sync'

# The config entry stating the desired values
#$Desired = $cfg.host.esxdns
$Desired= $cfg.manager.ntpIpAddresses

# The test value's data type, to help with conversion: bool/string/int
#$Type = 'string[]'
$Type

# The command(s) to pull the actual value for comparison
# $Object will scope to the folder this test is in (Cluster, Host, etc.)
<#
    [ScriptBlock]$Actual = {
        (Get-VMHostNetwork -VMHost $Object).DnsAddress
    }
#>
[ScriptBlock]$Actual = {

}


# The command(s) to match the environment to the config
# Use $Object to help filter, and $Desired to set the correct value
<#
    [ScriptBlock]$Fix = {
        Get-VMHostNetwork -VMHost $Object | Set-VMHostNetwork -DnsAddress $Desired -ErrorAction Stop
    }
#>
[ScriptBlock]$Fix = {

}