



function New-ChesterEndpoint {

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.String]$Path = "$Home\.chester",

        [ValidateSet('VMware.vSphere')]
        [System.String]$Provider,

        [System.String]$EnvironmentName
    )

    BEGIN {

        $endpointFullName = $null
        $endpointFullName = $Provider + "." + $EnvironmentName.ToUpper()

    }

    PROCESS {

        # test for .chester directory
        if (-not (Test-Path -Path $Path -PathType Container)) {

            try {
                New-Item -ItemType Directory -Path $Path -Force -ErrorAction 'Stop' | Out-Null
            } catch {
                throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not create .Chester directory { $Path }. $_"
            } # end try/catch

        } # end if

        try {
            New-Item -ItemType Directory -Path $Path\$endpointFullName -Force -ErrorAction 'Stop' | Out-Null
        } catch {
            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not create Chester endpoint directory { $Path }. $_"
        }


        try {

            $credSplat = $null
            $credSplat = @{
                Path        = "$Path\$endpointFullName\Authentication.clixml"
                Credential  = Get-Credential -Message "Enter the credentials for endpoint: $endpointFullName" -ErrorAction 'Stop'
                ErrorAction = 'stop'
            }

            Export-ChesterCredential @credSplat

        } catch {
            throw "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Could not export Endpoint credential. $_"
        }

    } # end PROCESS block

    END {

    }

} #function