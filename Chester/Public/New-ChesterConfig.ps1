

function New-ChesterConfig {
    <#
    .SYNOPSIS
    Generates a Vester config file from settings in your existing VMware environment.

    .DESCRIPTION
    New-VesterConfig is designed to be a quick way to get started with Vester.

    Vester needs one config file for each vCenter server it interacts with. To
    help speed up this one-time creation process, New-VesterConfig uses PowerCLI
    to pull current values from your environment to store in the config file.

    You'll be prompted with the list of Clusters/Hosts/VMs/etc. discovered, and
    asked to choose one of each type to use as a baseline; i.e. "all my other
    hosts should be configured like this one." Those values are displayed
    interactively, and you can manually edit them as desired.

    Optionally, advanced users can use the -Quiet parameter. This suppresses
    all host output and prompts. Instead, values are pulled from the first
    Cluster/Host/VM/etc. found alphabetically. Manual review afterward of the
    config file is strongly encouraged if using the -Quiet parameter.

    It outputs a single Config.json file at \Vester\Configs, which may require
    admin rights. Optionally, you can use the -OutputFolder parameter to
    specify a different folder to store the Config.json file.

    .EXAMPLE
    New-VesterConfig
    Ensures that you are connected to only one vCenter server.
    Based on all Vester test files found in '\Vester\Tests', the command
    discovers values from your environment and displays them, occasionally
    prompting for a selection of which cluster/host/etc. to use.
    Outputs a new Vester config file to '\Vester\Configs\Config.json',
    which may require admin rights.

    .EXAMPLE
    New-VesterConfig -Quiet -OutputFolder "$env:USERPROFILE\Desktop"
    -Quiet suppresses all host output and prompts, instead pulling values
    from the first cluster/host/etc. found alphabetically.
    Upon completion, Config.json will be created on your Desktop.

    .NOTES
    This command relies on the Pester and PowerCLI modules for testing.

    "Get-Help about_Vester" for more information.

    .LINK
    http://vester.readthedocs.io/en/latest/

    .LINK
    https://github.com/WahlNetwork/Vester
    #>
    [CmdletBinding()]
    param (


        [system.string]$Provider,

        [system.string]$Endpoint,

        [switch]$Quiet
    )

    BEGIN {



    } # BEGIN

    PROCESS{



    } # PROCESS

    END{


    } # END
}
