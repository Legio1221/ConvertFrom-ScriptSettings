<#
    <#
    .NOTES
    ======================================================
    Author: Oscar Guillermo Castro Jr.
    Date: September 26, 2019
    Organization: Jimenez & Associates
    Project: ConvertFrom-ScriptSettings
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
Import-Module "$PSScriptRoot/builds/dev/ConvertFrom-ScriptSettings/ConvertFrom-ScriptSettings.psd1" # Using the included build.

$config = ConvertFrom-ScriptSettings -ScriptSettingsFile "$PSScriptRoot/scriptsettings.json"
$source = $config["Nuget:Source"]
$version = $config["Version"]

Write-Debug "******************************************************"
Write-Debug "Source: $source |END"
Write-Debug "Version: $version |END"
Write-Debug "******************************************************"

if(!$source)
{
    throw [System.ArgumentNullException]::new('$Source', "Source variable is null! The variable is needed for nuget CLI. Is the scriptsettings key null?")
}

if(!$version)
{
    throw [System.ArgumentNullException]::new('$Version', "Version variable is null! The variable is needed for this script! Is the scriptsettings key null?")
}

# 1.) Create temporary PS Repository in ./packages
# ------------------------------------------------------
Write-Verbose "Creating temporary PS Repository."
$feed = "$PSScriptRoot/packages/feed"
$tempRepoName = "TempRepo"
$repositoryArguments = @{
    Name = $tempRepoName
    SourceLocation = $feed
    PublishLocation = $feed
    InstallationPolicy = 'Trusted'
}
Register-PSRepository @repositoryArguments

# 2.) Publish-Module to temporary repoistory & grab nupkg based on version.
# ------------------------------------------------------
Write-Verbose "Publising module to temporary repository."
$modulePath = "$PSScriptRoot/builds/$version/ConvertFrom-ScriptSettings" # Need folder name to match for Publish-Module
Publish-Module -Path $modulePath -Repository $tempRepoName -NuGetApiKey 'Fake-key-needed-for-function'

# GPR prefers that the nupkg have the same name as the repository. We can use the ProjectUrl in the nuspec too (set by the ProjectUri in the Module Manifest).
$original = "$PSScriptRoot/packages/feed/ConvertFrom-ScriptSettings.$version.nupkg"
$nupkg = "$PSScriptRoot/packages/ConvertFrom-ScriptSettings.nupkg"
Copy-Item -Path $original -Destination $nupkg

# 3.) Use Nuget CLI to publish to GPR. Requires proper access and proper config file!
# ------------------------------------------------------
nuget push $nupkg -Source $source

# 4.) Delete temporary PS repository
# ------------------------------------------------------
Unregister-PSRepository -Name $tempRepoName