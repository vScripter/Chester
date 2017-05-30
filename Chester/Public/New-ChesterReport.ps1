

function New-ChesterReport {

    [CmdletBinding(DefaultParameterSetName = 'default')]
    param (
        [System.String]$BinaryPath = "$((Split-Path $PSScriptRoot -Parent))\Private\ReportUnit.exe",
        #[System.String]$BinaryPath = "$PSScriptRoot\ReportUnit.exe",
        [System.String]$ReportPath = "$Home\.chester\_Report"
    )


    BEGIN {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing started"

        # clean report directort of HTML reports
        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Cleaning out stale reports located at { $ReportPath }"
        [void](Get-ChildItem -Path $ReportPath -Recurse -Filter '*.html' | Remove-Item -Force -ErrorAction SilentlyContinue)

    } # BEGIN

    PROCESS {

        # gather report files to process
        $reportFiles = $null
        $reportFiles = Get-ChildItem -Path $ReportPath -Filter '*.xml'

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Generating Report for the following reports { $($reportFiles.Name -join ', ') }"
        [void](& $BinaryPath $ReportPath)

        # gather HTML reports that need test replaced
        $htmlReportFiles = $null
        $htmlReportFiles = Get-ChildItem -Path $ReportPath -Filter '*.html'

        foreach ($htmlReport in $htmlReportFiles){

            Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Customizing Generated HTML report { $($htmlReport.Name) }"
            $html = $null
            [void]($html = Get-Content $htmlReport.FullName)
            [void]($html = $html.replace('http://reportunit.relevantcodes.com/',''))
            [void]($html = $html.replace('<span>ReportUnit</span>','<span>Chester</span>'))
            [void]($html = $html.replace('ReportUnit TestRunner Report','Chester Report'))
            [void](Out-File -InputObject $html -FilePath $htmlReport.Fullname -Encoding utf8 -Force)

        } # end foreach $htmlReport



    } # PROCESS

    END {

        Write-Verbose -Message "[$($PSCmdlet.MyInvocation.MyCommand.Name)] Processing completed"

    } # END

} # New-ChesterReport