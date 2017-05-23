

function Get-ChesterEndpoint {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]$Path = "$Home\.chester",

        <# control the type of value returned; use 'Names' as the default value so that when it's
        ran by a user, just a list of Endpoint names is returned. The 'Object' type will be specified
        when calling it internally, or be option by a user to inspect the endpoint configurations #>
        [ValidateSet('Names', 'Object')]
        [System.String]$ReturnType = 'Names'
    )

    BEGIN {

        # gather root Endpoint directories
        $discoveredEndpoints = $null
        $discoveredEndpoints = Get-ChildItem -Path $Path -Directory

        # create empty object to store full endpoint configurations
        [System.Object[]]$endpointConfiguration = $null

    }

    PROCESS {

        if ($ReturnType -eq 'Object') {

            ForEach ($endpoint in $discoveredEndpoints) {

                if (Test-Path "$($endpoint.FullName)\Config.json") {

                # import endpoint configuration
                $importedConfig = $null
                $importedConfig = Get-Content -Path (Get-Item "$($endpoint.FullName)\Config.json" -ErrorAction 'SilentlyContinue') -Raw -ErrorAction 'SilentlyContinue'| ConvertFrom-Json -ErrorAction 'SilentlyContinue'

                } else {

                    Write-Warning -Message "Configuration file not found for endpoint { $endpoint } at path { $($endpoint.FullName)\Config.json }"

                }

                # gather endpoint authentication
                $importedAuth = $null
                $importedAuth = Import-ChesterCredential -Path "$($endpoint.FullName)\Authentication.clixml" -ErrorAction 'SilentlyContinue'


                # add endpoint configuration to the final endpoint config array
                $endpointObj = @()
                $endpointObj = [PSCustomObject] @{
                    Name       = $endpoint.Name
                    Cfg        = $importedConfig
                    Credential = $importedAuth
                }

                $endpointConfiguration += $endpointObj

            } # end foreach $endpoint

        } elseif ($ReturnType -eq 'Names'){

            $discoveredEndpoints.Name

        } # if/else $ReturnType

    } # end PROCESS block

    END {

        $endpointConfiguration

    }

} #function