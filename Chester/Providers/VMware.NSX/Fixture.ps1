<#

    WIP

#>

[CmdletBinding()]
param(
    [System.String]$OutputFolder
)

BEGIN {

    Write-Verbose -Message "[VMware.NSX][$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"

} # BEGIN

PROCESS {

    $config = $null
    $config = [ordered]@{}

    $config.provider = "$($PSScriptRoot.Name)"

    $config.vcenter = @{
        vc = ''
    }

    $config.nsxmanager = @{
        manager = ''
    }

    $config.scope = [ordered]@{
        manager    = '*'
        controller = '*'
        vmhost     = '*'
        platform   = '*'
        cluster    = '*'
    }

    try {
        $config | ConvertTo-Json | Out-File -FilePath "$OutputFolder\Config.json" -Force -ErrorAction Stop
    } catch {
        Write-Warning -Message "[VMware.NSX][$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not export config file { $OutputFolder\Config.json }. $_"
    } # try/catch

} # PROCESS

END {

    Write-Verbose -Message "[VMware.NSX][$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"

} # END