

function New-ChesterProviderFixture {

    [CmdletBinding()]
    param(
        [System.String]$Name,
        [System.String[]]$Scopes,
        [System.String]$Path = "$((Split-Path $PSScriptRoot -Parent))\Providers"
    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"

        # test for .chester directory
        if (-not (Test-Path -Path $Path -PathType Container)) {

            try {
                New-Item -ItemType Directory -Path $Path -Force -ErrorAction 'Stop' | Out-Null
            } catch {
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not create .Chester directory { $Path }. $_"
            } # end try/catch

        } # end if

        if ($Name -notlike '*.*') {
            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][WARNING] Provider name does not appear to follow guidelines for new Provider names, which use the format: [Vendor].[Product]. Creation will continue."
        } # end

    } # BEGIN

    PROCESS {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Creating fixture for new provider { $Name }"

        # create provider directory
        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Creating provider directory { $Path\$Name }"
        if (Test-Path -Path "$Path\$Name" -PathType Container) {

            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Provider directory already exists at { $Path\$Name }."

        } else {

            try {
                [void](New-Item -ItemType Directory -Path "$Path\$Name" -Force -ErrorAction 'Stop')
            } catch {
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERRPR] Could not create provider directory { $Path\$Name }. $_"
            } # end try/catch

        } # end if/else


        # create Scopes directories & first test file
        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Creating provider Scope directory(s) under { $Path\$Name }"

        foreach ($scope in $Scopes) {

            try {
                [void](New-Item -ItemType Directory -Path "$Path\$Name\$scope" -Force -ErrorAction 'Stop')
            } catch {
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERRPR] Could not create provider Scope directory { $Path\$Name\$scope }. $_"
            } # end try/catch

            $testFileTemplate = $null
            $testFileTemplate = @"

<#
    Chester Test File
    -----------------
    Provider: $Name
    Scope   : $scope
#>

# Test title (e.g. 'DNS Servers')
#`$Title = 'DNS Servers'
`$Title

# Test description: How the module explains this value to the user
#`$Description = 'DNS address(es) for the host to query against'
`$Description

# The config entry stating the desired values
#`$Desired = `$cfg.host.esxdns
`$Desired

# The test value's data type, to help with conversion: bool/string/int
#`$Type = 'string[]'
`$Type

# The command(s) to pull the actual value for comparison
# `$Object will scope to the folder this test is in (Cluster, Host, etc.)
<#
    [ScriptBlock]`$Actual = {
        (Get-VMHostNetwork -VMHost `$Object).DnsAddress
    }
#>
[ScriptBlock]`$Actual = {

}


# The command(s) to match the environment to the config
# Use `$Object to help filter, and `$Desired to set the correct value
<#
    [ScriptBlock]`$Fix = {
        Get-VMHostNetwork -VMHost `$Object | Set-VMHostNetwork -DnsAddress `$Desired -ErrorAction Stop
    }
#>
[ScriptBlock]`$Fix = {

}

"@

            try {
                [void](New-Item -ItemType File -Path "$Path\$Name\$scope\Test.Vester.ps1" -Force -ErrorAction 'Stop')

                [void](Add-Content -Path "$Path\$Name\$scope\Test.Vester.ps1" -Encoding UTF8 -Value $testFileTemplate -Force)
            } catch {
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERRPR] Could not create provider Scope test file { $Path\$Name\$scope\ReplaceMe.Vester.ps1 }. $_"
            } # end try/catch

        } # foreach $scope



        # create Fixture.ps1 file
        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Creating Fixture.ps1 file { $Path\$Name\Fixture.ps1 }"
        try {

            [void](New-Item -ItemType File -Path "$Path\$Name\Fixture.ps1" -Force -ErrorAction 'Stop')

        } catch {

            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERRPR] Could not create Fixture.ps1 { $Path\$Name\Fixture.ps1 }. $_"

        } # end try/catch


        # create Init.Tests.ps1 file
        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Creating Init.Tests.ps1 file { $Path\$Name\Init.Tests.ps1 }"

        $initTestFileHeader = $null
        $initTestFileHeader = @"
<# This is a placeholder test file that was automatically generated. You
can delete it, and/or rename it, and populate it with the desired test material. #>

[CmdletBinding(SupportsShouldProcess = `$true, ConfirmImpact = 'Medium')]
Param(
    # The `$cfg hashtable from a single config file
    [object]`$Cfg,

    # Array of paths for tests in the current provider directory
    [object]`$TestFiles,

    # Pass through the user's preference to fix differences or not
    [switch]`$Remediate
)

Write-Verbose -Message "[$Name][`$(`$PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"


# some code, maybe a lot of it, which defines the execution of tests for this provider


Write-Verbose -Message "[$Name][`$(`$PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"
"@

        try {

            [void](New-Item -ItemType File -Path "$Path\$Name\Init.Tests.ps1" -Force -ErrorAction 'Stop')
            [void](Add-Content -Path "$Path\$Name\Init.Tests.ps1" -Encoding UTF8 -Value $initTestFileHeader -Force)

        } catch {

            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERRPR] Could not create Init.Tests.ps1 { $Path\$Name\Init.Tests.ps1 }. $_"

        } # end try/catch

    } # PROCESS

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"

    } # END

} # New-ChesterProviderFixture