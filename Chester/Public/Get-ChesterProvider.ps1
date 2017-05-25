

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

        $discoveredProvider = $null

        if ($PSBoundParameters.Keys.Contains('ProviderName')) {

            $providerArray = @()

            foreach ($provider in $ProviderName) {

                Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Looking for Provider { $provider }"

                $fetchProvider = $null
                $fetchProvider = Get-ChildItem -Path $Path -Directory | Where-Object {$_.Name -eq $provider}

                if ($fetchProvider -eq $null) {
                    Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Provider { $provider } could not be found."
                }

                $providerArray += $fetchProvider

            } # end foreach

            $discoveredProvider = $providerArray

        } else {

            $discoveredProvider = Get-ChildItem -Path $Path -Directory

        } # end if/else

        # create empty object to store full endpoint configurations
        [System.Object[]]$providerConfiguration = $null

    }

    PROCESS {

        switch ($ReturnType) {

            'Object' {

                ForEach ($provider in $discoveredProvider) {

                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Provider { $provider }"



                    # discover Scopes
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Discovering Scopes for Provider { $provider }"

                    $providerScopes = $null
                    $providerScopes = (Get-ChildItem -Path $provider.FullName -Directory).Name



                    # discover test/test files
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Discovering Tests for Provider { $provider }"

                    $scopeHash = @{
                        Name       = 'Scope'
                        Expression = {
                            (Get-item (Split-Path $_.FullName -Parent)).Name
                        }
                    } # $scopeHash

                    $testHash = @{
                        Name       = 'Test'
                        Expression = {
                            ($_.Name).Split('.')[0]
                        }
                    } # $testHash

                    $providerTests = $null
                    $providerTests = Get-ChildItem -Path $provider.FullName -Recurse -Filter '*.Vester.ps1' | Select-Object $testHash,$scopeHash



                    # discover config creation script
                    Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Discovering Configuration Creation Script for Provider { $provider }"



                    if (Test-Path "$($provider.FullName)\Config-Spec.ps1") {

                        $createConfigScript = $null
                        $createConfigScript = "$($provider.FullName)\Config-Spec.ps1"

                    } else {

                        Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Configuration Creation Script file not found for endpoint { $provider } at path { $($provider.FullName)\Config-Spec.ps1 }"

                    } # end if/else


                    # add provider configuration to the final provider config array
                    $providerObj = @()
                    $providerObj = [PSCustomObject] @{
                        Name               = $provider.Name
                        Scopes             = $providerScopes
                        Tests              = $providerTests
                        CreateConfigScript = $createConfigScript
                    }

                    $providerConfiguration += $providerObj

                } # end foreach $endpoint

                $providerConfiguration

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