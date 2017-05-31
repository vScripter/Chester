<# This is a placeholder test file that was automatically generated. You
can delete it, and/or rename it, and populate it with the desired test material. #>

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
Param(
    # The $cfg hashtable from a single config file
    [object]$Cfg,

    # Array of paths for tests in the current provider directory
    [object]$TestFiles,

    # Pass through the user's preference to fix differences or not
    [switch]$Remediate
)

Write-Verbose -Message "[VMware.NSX][$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"


# some code, maybe a lot of it, which defines the execution of tests for this provider


Write-Verbose -Message "[VMware.NSX][$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"
