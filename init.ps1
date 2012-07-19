param($installPath, $toolsPath, $package, $project)
Import-Module (Join-Path $toolsPath NuGetDependencyManagement.psd1)

Write-Host ""
Write-Host "*************************************************************************************"
Write-Host " INSTRUCTIONS"
Write-Host "*************************************************************************************"
Write-Host " - NuGetDependencyManagement creates a build directory in the solution directory"
Write-Host "   with a publish.nuspec file that defines the nuget package to publish. EDIT THIS FILE"
Write-Host "   with the files to publish, the internal nuget feed, etc. versions are generated at publish."
Write-Host ""
Write-Host " - NuGetDependencyManagement provides two commands 'Publish-Dependencies' and 'Update-Dependencies" 
Write-Host "   with a publish.nuspec file that defines the nuget package to publish."
Write-Host "*************************************************************************************"
Write-Host ""