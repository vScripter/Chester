

function Invoke-Chester {
    <#
    .SYNOPSIS
    Test and fix configuration drift in your VMware vSphere environment.

    .DESCRIPTION
    Invoke-Vester will run each test it finds and rendpointort on discrendpointancies.
    It compares actual values against the values you supply in a config file,
    and can fix them immediately if you include the -Remediate parameter.

    If you are not already connected to the vCenter server defined in the
    config file, Invoke-Vester will prompt for credentials to connect to it.

    Invoke-Vester then calls Pester to run each test file. The test files
    leverage PowerCLI to gather values for comparison/remediation.

    .EXAMPLE
    Invoke-Vester -Verbose
    Using the default config file at \Vester\Configs\Config.json,
    Vester will run all included tests inside of \Vester\Tests\.
    Verbose output will be displayed on the screen.
    It outputs a rendpointort to the host of all passed and failed tests.

    .EXAMPLE
    Invoke-Vester -Config C:\Tests\Config.json -Test C:\Tests\
    Vester runs all *.Vester.ps1 files found underneath the C:\Tests\ directory,
    and compares values to the config file in the same location.
    It outputs a rendpointort to the host of all passed and failed tests.

    .EXAMPLE
    $DNS = Get-ChildItem -Path Z:\ -Filter *dns*.Vester.ps1 -File -Recurse
    PS C:\>(Get-ChildItem -Path Z:\ -Filter *.json).FullName | Invoke-Vester -Test $DNS

    Get all Vester tests below Z:\ with 'dns' in the name; store in variable $DNS.
    Then, pipe all *.json files at the root of Z: into the -Config parameter.
    Each config file piped in will run through all $DNS tests found.

    .EXAMPLE
    Invoke-Vester -Test .\Tests\VM -Remediate -WhatIf
    Run *.Vester.ps1 tests in the .\Tests\VM path below the current location.
    For all tests that fail against the values in \Configs\Config.json,
    -Remediate attempts to immediately fix them to match your defined config.
    -WhatIf prevents remediation, and instead rendpointorts what would have changed.

    .EXAMPLE
    Invoke-Vester -Config .\Config-Dev.json -Remediate
    Run all \Vester\Tests\ files, and compare values to those defined within
    the Config-Dev.json file at the current location.
    For all failed tests, -Remediate attempts to immediately correct your
    infrastructure to match the previously defined values in your config file.

    .EXAMPLE
    Invoke-Vester -XMLOutputFile .\vester.xml
    Runs Vester with the default config and test files.
    Uses Pester to send test results in NUnitXML format to vester.xml
    at your current folder location.
    Option is primarily used for CI/CD integration solutions.

    .INPUTS
    [System.Object]
    Accendpointts piped input (optional multiple objects) for parameter -Config

    .NOTES
    This command relies on the Pester and PowerCLI modules for testing.

    "Get-Help about_Vester" for more information.

    .LINK
    http://vester.readthedocs.io/en/latest/

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    # ^ that passes -WhatIf through to other tests
    param (
        <#

        # Optionally define a different config file to use
        # Defaults to \Vester\Configs\Config.json
        [Parameter(ValueFromPipeline = $True,
            ValueFromPipelinebyPropertyName = $True)]
        [ValidateScript( {
                If ($_.FullName) {Test-Path $_.FullName}
                Else {Test-Path $_}
            })]
        [Alias('FullName')]
        [object[]]$Config = "$(Split-Path -Parent $PSScriptRoot)\Configs\Config.json",

        # Optionally define the file/folder of test file(s) to call
        # Defaults to \Vester\Tests\, grabbing all tests recursively
        # All test files must be named *.Vester.ps1
        [ValidateScript( {
                If ($_.FullName) {Test-Path $_.FullName}
                Else {Test-Path $_}
            })]
        [Alias('Path', 'Script')]
        [object[]]$Test = "$(Split-Path -Parent $PSScriptRoot)\Tests\",

        #>
        [Parameter(ValueFromPipeline = $True)]
        [object[]]$Endpoint = (Get-ChesterEndpoint -ReturnType 'Object'),

        # Optionally fix all config drift that is discovered
        # Defaults to false (disabled)
        [switch]$Remediate = $false,

        # Optionally save Pester output in NUnitXML format to a specified path
        # Specifying a path automatically triggers Pester in NUnitXML mode
        [ValidateScript({Test-Path $_ -PathType Container})]
        [string]$XMLOutputPath = "$Home\.chester\_Report",

        [switch]$GenerateReport,

        # Optionally returns the Pester result as an object containing the information about the whole test run, and each test
        # Defaults to false (disabled)
        [switch]$PassThru = $false,

        [switch]$Quiet

    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"

        $resolvedEndpoint = $null

        <#
        if ($PSBoundParameters.Keys.Contains('Endpoint')){

            $resolvedEndpoint = Get-ChesterEndpoint -EndpointName $Endpoint -ReturnType 'Object'

        } else {

            $resolvedEndpoint = Get-ChesterEndpoint -ReturnType 'Object'

        } # end if/else
        #>

    } #Begin

    PROCESS {

        foreach ($resolvedEndpoint in $endpoint) {

            <#

                - Loop through the endpoints that are discovered
                - for each endpoint, discover proper 'Provider' so that the proper 'Init' tests file can be called (must be part of the config)
                - Need to also handle connections using the credentials specified, somehow...

            #>

            # get the endpoint provider
            $endpointProvider = $null
            $endpointProvider = $resolvedEndpoint.cfg.Provider

            Write-Verbose "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Endpoint Provider { $endpointProvider }"

            <#  CONNECTIONS

                    Need to figure out how to better handle/check connections. If this is to support multiple endpoints,
                    there has to be a way to check for the connection type; not all of them might be vCenter

                    Initially, the idea is to possibly use PoshRSJob and force a brand new connection and run the child process in a new runspace,
                    for each Endpoint

            #>

            # Check for established session to desired vCenter server
            If ($resolvedEndpoint.cfg.vcenter.vc -notin $global:DefaultVIServers.Name) {

                Try {
                    # Attempt connection to vCenter; prompts for credentials if needed
                    Write-Verbose "[$($PSCmdlet.MyInvocation.MyCommand.Name)] No active connection found to configured vCenter { $($resolvedEndpoint.cfg.vcenter.vc) }. Connecting"
                    $VIServer = Connect-VIServer -Server $resolvedEndpoint.cfg.vcenter.vc -Credential $resolvedEndpoint.credential -ErrorAction Stop
                } Catch {
                    # If unable to connect, stop
                    throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Unable to connect to configured vCenter { $($resolvedEndpoint.cfg.vcenter.vc) }. $_ . Exiting."
                }

            } Else {

                $VIServer = $global:DefaultVIServers | Where-Object {$_.Name -match $resolvedEndpoint.cfg.vcenter.vc}

            } # end if/else

            Write-Verbose "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Provider\Endpoint { $endpointProvider\$($resolvedEndpoint.Name) }"

            # Call Invoke-Pester based on the parameters supplied
            # Runs VesterTemplate.Tests.ps1, which constructs the .Vester.ps1 test files
            <#

                    - Need to include checking for the Name/Type of the Provider and then pull in the tests from that Provider
                    - Have the Invoke-Pester cmdlet call the 'Init.Tests.ps1' file from the Provider directory

                #>

            $providerPath = $null
            $providerPath = "$(Split-Path -Parent $PSScriptRoot)\Providers\$endpointProvider"

            if (-not (Test-Path -Path $providerPath)){
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Provider { $endpointProvider } could not found at path { $providerPath }"
            }


            $initPath = $null
            $initPath = Join-Path $providerPath 'Init.Tests.ps1'

            if (-not (Test-Path -Path $initPath)){
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Init file not found for Provider { $endpointProvider } at path { $providerPath } "
            }

            Write-Verbose "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Provider path { $providerPath }"
            Write-Verbose "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Init path { $initPath }"

            If ($GenerateReport) {

                if ($Quiet) {

                    Invoke-Pester -OutputFormat NUnitXml -OutputFile "$XMLOutputPath\$($resolvedEndpoint.Name).xml" -Quiet -Script @{
                        #Path       = "$(Split-Path -Parent $PSScriptRoot)\Providers\Template\VesterTemplate.Tests.ps1"
                        Path       = $initPath
                        Parameters = @{
                            Cfg       = $resolvedEndpoint.cfg
                            TestFiles = Get-VesterTest $providerPath
                            Remediate = $Remediate
                        }
                    } # Invoke-Pester

                    New-ChesterReport


                } else {

                    Invoke-Pester -OutputFormat NUnitXml -OutputFile "$XMLOutputPath\$($resolvedEndpoint.Name).xml" -Script @{
                        #Path       = "$(Split-Path -Parent $PSScriptRoot)\Providers\Template\VesterTemplate.Tests.ps1"
                        Path       = $initPath
                        Parameters = @{
                            Cfg       = $resolvedEndpoint.cfg
                            TestFiles = Get-VesterTest $providerPath
                            Remediate = $Remediate
                        }
                    } # Invoke-Pester

                    New-ChesterReport

                } # end if/else

            } ElseIf ($PassThru) {

                if ($Quiet) {

                    Invoke-Pester -PassThru -Quiet -Script @{
                        Path       = $initPath
                        Parameters = @{
                            Cfg       = $resolvedEndpoint.cfg
                            TestFiles = Get-VesterTest $providerPath
                            Remediate = $Remediate
                        }
                    } # Invoke-Pester

                } else {

                    Invoke-Pester -PassThru -Script @{
                        Path       = $initPath
                        Parameters = @{
                            Cfg       = $resolvedEndpoint.cfg
                            TestFiles = Get-VesterTest $providerPath
                            Remediate = $Remediate
                        }
                    } # Invoke-Pester

                } # end if/else

            } Else {

                if ($Quiet) {

                    Invoke-Pester -Qiuet -Script @{
                        Path       = $initPath
                        Parameters = @{
                            Cfg       = $resolvedEndpoint.cfg
                            TestFiles = Get-VesterTest $providerPath
                            Remediate = $Remediate
                        }
                    } # Invoke-Pester

                } else {

                    Invoke-Pester -Script @{
                        Path       = $initPath
                        Parameters = @{
                            Cfg       = $resolvedEndpoint.cfg
                            TestFiles = Get-VesterTest $providerPath
                            Remediate = $Remediate
                        }
                    } # Invoke-Pester

                } # end if/else

            } #If XML

            # In case multiple config files were provided and some aren't valid
            #$cfg = $null

            #} #ForEach Config (original vester code)

        } # end foreach EndPoint

    } #Process

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"

    } # end END block

} #function
