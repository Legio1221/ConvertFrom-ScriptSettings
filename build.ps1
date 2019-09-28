<#
    <#
    .NOTES
    ======================================================
    Author: Oscar Guillermo Castro Jr.
    Date: September 26, 2019
    Organization: Jimenez & Associates
    Project: ConvertFrom-ScriptSettings.psm1
    Version: 1.0.0
    ======================================================

    .SYNOPSIS
    ======================================================
    Publishes to Github Package Registry! Uses a hack-ish manner to get the nupkg to Github.
    Requires access to the appropriate repository!
    Requires that nuget CLI config file be set up!
    ======================================================
#>

# 0.) Setup
# ------------------------------------------------------
# Assuming ConvertFrom-ScriptSettings is not available.
$json = Get-Content -Path "$PSScriptRoot/scriptsettings.json" -Raw | ConvertFrom-Json
$version = $json.'Version'
$module = "ConvertFrom-ScriptSettings"
$moduleFolder = "$PSScriptRoot/builds/$version/$module"

# 1.) Build and Publish
# ------------------------------------------------------
try 
{
    $output = "$moduleFolder/bin"
    dotnet publish --output $output # dotnet-publish publishes the output directory relative to the csproj's path.
}
catch 
{
    Write-Error "Unable to build and publish solution!"
    break
}

# 2.) Create Module Manifest and Module Script Root
# # ------------------------------------------------------
$manifestName = "ConvertFrom-ScriptSettings.psd1"
$moduleRootName = "ConvertFrom-ScriptSettings.psm1"

New-Item -Path $moduleFolder -Name "$moduleRootName" -ItemType "file" -Value "# Purposefully empty, reserved for future use."

$binFolder = Get-ChildItem -Path $output

$files = @()
foreach($file in $binFolder)
{
    $files += "bin/$($file.Name)"
}

$manifestArguments = @{
    Path = "$moduleFolder/$manifestName"
    RootModule = "$moduleRootName"
    Author = "Legio1221"
    ModuleVersion = "$version"
    CompanyName = "Jimenez & Associates"
    Description = "Simple AppSettings for PowerShell"
    RequiredAssemblies = $files
    NestedModules = "bin/scriptsettings.dll"
    ProjectUri = "https://github.com/Legio1221/ConvertFrom-ScriptSettings"
}

New-ModuleManifest @manifestArguments
Test-ModuleManifest -Path "$moduleFolder/$manifestName"