<#
    .NOTES
    ======================================================
    Author: Oscar Guillermo Castro Jr.
    Date: September 26, 2019
    Organization: Jimenez & Associates
    File Name: ScriptSettings.Tests.ps1
    Version: 1.0.0
    ======================================================

    .SYNOPSIS
    ======================================================
    Tests for 'ConvertFrom-ScriptSettings' functionality
    ======================================================
#>

Describe "ConvertFrom-ScriptSettings Tests" {

    # We'll need the ScriptSettings module to get any work done hehe
    $module = "$PSScriptRoot/../builds/ConvertFrom-ScriptSettings.psd1"
    Import-Module $module
    Context "Integration Testing" {
        # ScriptSettings.json - Default
        # ScriptSettings.Tests.json - Environment Variable
        # ScriptSettings.Shazam.json - Specified by file

        # Set the Tests environment variable for integration tests, removed after all 'It' tests.
        $env:POWERSHELLCORE_ENVIRONMENT = "Tests"

        # Save the current working directory as we need to change directories to 'tests'.
        $currentWorkingDirectory = $PWD.Path

        # Change the directory to 'Tests'
        # ======================================================
        Set-Location -Path "$PSScriptRoot"

        It "loads the 3 ScriptSettings.json files and loads variables in order" {
            $file = "$PSScriptRoot/scriptsettings.shazam.json"
            $config = ConvertFrom-ScriptSettings -ScriptSettingsFile $file

            $config["Awesome Album:Artist"] | Should -BeExactly "Post Malone"
            $config["Awesome Album:Album"] | Should -BeExactly "Hollywood's Bleeding"
            $config["Awesome Album:Best Song"] | Should -BeExactly "Circles"

            $config["Spectacular Quote:Author"] | Should -BeExactly 'GAIVS IVLIVS CAESAR'
            $config["Spectacular Quote:Quote"] | Should -BeExactly 'VENI VEDI VICI'

            $config["Wonderful Book:Author"] | Should -BeExactly "Homer"
            $config["Wonderful Book:Title"] | Should -BeExactly "The Odyssey"

            $config["Fictitious Integers:0"] | Should -Be 12345
            $config["Fictitious Integers:1"] | Should -Be 67890
            $config["Fictitious Integers:2"] | Should -Be 1221
        }

        It "throws because the specified file does not exist." {
            $file = "$PSScriptRoot/scriptsettings.doesnotexist.json"

            { ConvertFrom-ScriptSettings -ScriptSettingsFile $file } | Should throw
        }

        It "Loads only the default file with the environment variable is null" { 
            Write-Debug "======================================================"
            Write-Debug "Beginning #3 integration tests"

            $env:POWERSHELLCORE_ENVIRONMENT = $null

            Write-Debug "Current Working Directory: $pwd"

            $config = ConvertFrom-ScriptSettings

            $config["Awesome Album:Artist"] | Should -BeExactly "The Weeknd"
            $config["Awesome Album:Album"] | Should -BeExactly "Starboy"
            $config["Awesome Album:Best Song"] | Should -BeExactly "Starboy (feat. Daft Punk)"

            $config["Spectacular Quote:Author"] | Should -BeExactly 'GAIVS IVLIVS CAESAR'
            $config["Spectacular Quote:Quote"] | Should -BeExactly 'VENI VEDI VICI'

            $config["Wonderful Book:Author"] | Should -BeExactly "J.K. Rowling"
            $config["Wonderful Book:Title"] | Should -BeExactly "Harry Potter and the Sorcerer's Stone"

            $env:POWERSHELLCORE_ENVIRONMENT = "Tests"
        }

        # Set environment and working directory back to pre-tests.
        Set-Location -Path $currentWorkingDirectory
        $env:POWERSHELLCORE_ENVIRONMENT = $null
    }
}