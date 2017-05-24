

function Get-ChesterProvider {

    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (


        [Parameter(Position = 0)]
        [System.String[]]$ProviderName,


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
        [System.String]$Path = "$(Split-Path $PSScriptRoot -Parent)\Providers"

    )

    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"

        if ($PSBoundParameters.Keys.Contains('ProviderName')) {

            $providerArray = @()

            foreach ($provider in $ProviderName) {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Looking for Provider { $provider }"

                $fetchProvider = $null
                $fetchProvider = Get-ChildItem -Path $Path -Directory | Where-Object {$_.Name -eq $provider}

                $providerArray += $fetchProvider

            } # end foreach

            # gather root Endpoint directories
            $discoveredProvider = $null
            $discoveredProvider = $providerArray

        } else {

            # gather root Endpoint directories
            $discoveredProvider = $null
            $discoveredProvider = Get-ChildItem -Path $Path -Directory

        } # end if/else

        # create empty object to store full endpoint configurations
        [System.Object[]]$providerConfiguration = $null

    }

    PROCESS {

        switch ($ReturnType) {

            'Object' {

                ForEach ($provider in $discoveredProvider) {

                    if (Test-Path "$($provider.FullName)\Config.json") {

                        # import endpoint configuration
                        $importedConfig = $null
                        $importedConfig = Get-Content -Path (Get-Item "$($endpoint.FullName)\Config.json" -ErrorAction 'SilentlyContinue') -Raw -ErrorAction 'SilentlyContinue'| ConvertFrom-Json -ErrorAction 'SilentlyContinue'

                    } else {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Configuration file not found for endpoint { $endpoint } at path { $($endpoint.FullName)\Config.json }"

                    } # end if/else


                    $createConfigScript = $null
                    $newConfigFileName  = $null
                    $newConfigFileName  = 'Create-Config.' + $endpoint.Name + '.ps1'

                    if (Test-Path "$($endpoint.FullName)\$newConfigFileName") {

                        $createConfigScript = $newConfigFileName

                    } else {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] New Configuration Script file not found for endpoint { $endpoint } at path { $($endpoint.FullName)\$newConfigFileName }"

                    } # end if/else

                    # gather endpoint authentication
                    $importedAuth = $null
                    $importedAuth = Import-ChesterCredential -Path "$($endpoint.FullName)\Authentication.clixml" -ErrorAction 'SilentlyContinue'

                    # add endpoint configuration to the final endpoint config array
                    $providerObj = @()
                    $providerObj = [PSCustomObject] @{
                        Name               = $endpoint.Name
                        Scopes             = $importedConfig
                        Tests              = $importedAuth
                        CreateConfigScript = $createConfigScript
                    }

                    $endpointConfiguration += $providerObj

                } # end foreach $endpoint

                $endpointConfiguration

            } # end 'Object'

            'Names' {

                $discoveredEndpoints.Name

            } # end 'Names'

        } # end switch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing complete"

    }

} #function