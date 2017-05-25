

function Get-ChesterEndpoint {

    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (


        [Parameter(Position = 0)]
        [System.String[]]$EndpointName,


        <# control the type of value returned; use 'Names' as the default value so that when it's
        ran by a user, just a list of Endpoint names is returned. The 'Object' type will be specified
        when calling it internally, or be option by a user to inspect the endpoint configurations #>
        [Parameter(Position = 1)]
        [ValidateSet('Name', 'Object')]
        [System.String]$ReturnType = 'Object',


        [Parameter(Position = 2, ValueFromPipeline = $true)]
        [ValidateScript( {
                Test-Path -Path $_ -PathType Container
            })]
        [System.String]$Path = "$Home\.chester"

    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"

        if ($PSBoundParameters.Keys.Contains('EndpointName')) {

            $epArray = @()

            foreach ($endpointEntry in $EndpointName) {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Looking for Endpoint { $endpointEntry }"

                $fetchEndpoint = $null
                $fetchEndpoint = Get-ChildItem -Path $Path -Directory | Where-Object {$_.Name -eq $endpointEntry}

                if($fetchEndpoint -eq $null) {
                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Endpoint { $endpointEntry } could not be found."
                }

                $epArray += $fetchEndpoint

            } # end foreach

            # gather root Endpoint directories
            $discoveredEndpoints = $null
            $discoveredEndpoints = $epArray

        } else {

            # gather root Endpoint directories
            $discoveredEndpoints = $null
            $discoveredEndpoints = Get-ChildItem -Path $Path -Directory

        } # end if/else

        # create empty object to store full endpoint configurations
        [System.Object[]]$endpointConfiguration = $null

    }

    PROCESS {

        switch ($ReturnType) {

            'Object' {

                ForEach ($endpoint in $discoveredEndpoints) {

                    if (Test-Path "$($endpoint.FullName)\Config.json") {

                        # import endpoint configuration
                        $importedConfig = $null
                        $importedConfig = Get-Content -Path (Get-Item "$($endpoint.FullName)\Config.json" -ErrorAction 'SilentlyContinue') -Raw -ErrorAction 'SilentlyContinue'| ConvertFrom-Json -ErrorAction 'SilentlyContinue'

                    } else {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Configuration file not found for endpoint { $endpoint } at path { $($endpoint.FullName)\Config.json }"

                    } # end if/else

                    # gather endpoint authentication
                    $importedAuth = $null
                    $importedAuth = Import-ChesterCredential -Path "$($endpoint.FullName)\Authentication.clixml" -ErrorAction 'SilentlyContinue'

                    # add endpoint configuration to the final endpoint config array
                    $endpointObj = @()
                    $endpointObj = [PSCustomObject] @{
                        Name               = $endpoint.Name
                        Cfg                = $importedConfig
                        Credential         = $importedAuth
                    }

                    $endpointConfiguration += $endpointObj

                } # end foreach $endpoint

                $endpointConfiguration

            } # end 'Object'

            'Name' {

                $discoveredEndpoints.Name

            } # end 'Names'

        } # end switch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"

    }

} #function