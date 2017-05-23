function Import-ChesterCredential {
    <#
    .SYNOPSIS
        Import an encrypted PS credential for use
    .DESCRIPTION
        Import an encrypted PS credential for use

    .PARAMETER Path
        Path to where you wish to import the credential file from
    .INPUTS
        System.String
    .EXAMPLE
        Import-ChesterCredential -Path C:\User123Credential.xml
    .NOTES
        Author: Kevin Kirkpatrick
        Social: Twitter|GitHub|Slack @vScripter
        Version: 1.0
        Last Updated: 20170519
        Last Updated By: K. Kirkpatrick
        Last Update Notes:
        - Added to module
    #>

    [cmdletbinding()]
    param
    (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path -LiteralPath $_ -PathType Leaf })]
        [System.String]$Path
    )

    BEGIN {

    } # end BEGIN block

    PROCESS {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Importing credential from credential file {$Path}"
        try {

            $CredentialCopy = Import-Clixml $path -ErrorAction 'Stop'
            $CredentialCopy.password = $CredentialCopy.Password | ConvertTo-SecureString -ErrorAction 'Stop'
            New-Object System.Management.Automation.PSCredential($CredentialCopy.username, $CredentialCopy.password)

        } catch {

            Write-Warning -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)][ERROR] Could not import credential. $_"

        } # end try/catch

    } # end PROCESS block

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing Complete."

    } # end END block

} # end function Import-ChesterCredential