﻿<#

                             ``````````````````
                       `.-://///////////////////::.`
                     `-///-...```````````````..-:///-
                    `://-                         -//:`
                    -//.                           .//-
                    ://`                           `//:
                    ://`                           `//:
                    ://`                           `//:
                    ://`                           `//:
                  ``://`                           `//:`
            `.-:://////`                           `/////::-.`
         `-:///:--.`://.                           .//:.--:///:-
        `//:-`      .:////::::----------------:::////:.     `-//:
        `//:.`        `..----:::::::::::::::::----..`       `-//:
         `-:///:-..``                                ``.--:///:.
            `.-:://////:::----..............----:::///////:-.`
                `///..---::::://////////////:::::---..`///`
                 ://.                                 .//:
               `://-`                    .-:///:-.````.://:`
               -//.      `--------.    `://:-.-:///////////-
               -//.      -:///////:`   ://.     .//:````-//-
               .//:         `::-      `///      `//:    ://.
                ://.                   -//:`   .://.   .//:
                `://:.                  .:///////:.  .://:
                  .//:                    `..-..`    ://.
                   ://`                             `//:
                   .//:          .-::--:-.          ://.
                    -//-        -//:://://:        -//-
                     ://.   ....://` `  ://.`.-`  .//:
                     `://` `:////:.     `://///- `//:`
                      `://.  ````          ```  .//:`
                       `///:.                 .:///`
                        //////-.           .-//////
                       .//-`.:///:-.-----:///:.`-//.
                 ``.--:///`   `.-:///////:-.`   `///:--..``
           `.--://///::://:.`      `///`      `.://::://///::-.`
       `.-:///:--.``    `-///:.`    ///    `.:///-`     `..-:////:-`
    `.:///:-`              .-:///::-///-::////-.              `.-://:-`
  `-///-.                     `.--::///::--.`                     `-://:.
 `//:.                              ///                              .://.
 `//:                               ///                               -//.
  .///::---..````                   ///                   ```...---::///-
    ..--:://///////:::::----------..///.-----------:::://////////::--..`
            ```...-----:::::::///////////////:::::::----....```


  ______  __    __   _______     _______.___________. _______ .______
 /      ||  |  |  | |   ____|   /       |           ||   ____||   _  \
|  ,----'|  |__|  | |  |__     |   (----`---|  |----`|  |__   |  |_)  |
|  |     |   __   | |   __|     \   \       |  |     |   __|  |      /
|  `----.|  |  |  | |  |____.----)   |      |  |     |  |____ |  |\  \----.
 \______||__|  |__| |_______|_______/       |__|     |_______|| _| `._____|



#>


# Gather all files
$PublicFunctions  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
$PrivateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

# Dot source the functions
ForEach ($File in @($PublicFunctions + $PrivateFunctions)) {
    Try {
        . $File.FullName
    } Catch {
        Write-Error -Message "Failed to import function $($File.FullName): $_"
    }
}

# Export the public functions for module use
Export-ModuleMember -Function $PublicFunctions.Basename
