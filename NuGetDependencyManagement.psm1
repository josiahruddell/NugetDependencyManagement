function Publish-Dependencies {
    # Creates a nuget package off the publish.nuspec and pushes it to the server
    $source = Check-GetDependencyManagementServer
    $solutionDir = Get-SolutionDir
    $buildPath = (Join-Path $solutionDir build)
    $publishSpec = (Join-Path $buildPath publish.nuspec)

    Write-Host "Build directory: $buildPath"
    nuget pack $publishSpec -OutputDirectory $buildPath
    $packagePath = (Join-Path $buildPath *.nupkg)
    nuget push $packagePath -Source $source
    
    # cleanup the package after push
    Write-Host "Cleaning up..."
    Remove-Item $packagePath -force
}

function Update-Dependencies {
    param(
        [string[]]$Dependency
    )
    $source = Check-GetDependencyManagementServer $true
    # Update Dependencies only from the dependency management server
    Get-Project -All | %{ 
        $name = $_.Name
        Write-Host "Looking for updates in $name"
        # $projDir = Get-ChildItem $_.FullName | Select-Object Directory 
        # Specifying the source ensures that only packages from the dependency management feed will be undated
        if($Dependency) {
            #nuget update $packagesPath $Dependency -source "http://nuget.staging.alkamitech.com"
            Update-Package -PackageId $Dependency -Project $_.FullName -Source $source
        }
        else {
            # nuget update $packagesPath -source "http://nuget.staging.alkamitech.com"
            Update-Package -Project $_.FullName -Source $source
        }
    }
}

function Set-DependencyManagementServer {
    param(
        [string[]]$Server = "http://nuget.staging.alkamitech.com",
        [string[]]$UpdateServer = ""
    )

    if(!$UpdateServer){
        $UpdateServer = "$Server/nuget"
    }
   
    if($Server){
        Write-Host "Storing update url: $UpdateServer"
        nuget config -Set DependencyManagementServerUpdateUrl=$UpdateServer
        Write-Host "Storing publish url: $Server"
        nuget config -Set DependencyManagementServerPublishUrl=$Server
    }
}

function Get-DependencyManagementServer {
    param( [bool]$updateUrl = $false )

    Check-DependencyManagementServerExists
    
    if($updateUrl){
        return nuget config DependencyManagementServerUpdateUrl
    }
    return nuget config DependencyManagementServerPublishUrl
}


function Check-DependencyManagementServerExists {
    $server = nuget config DependencyManagementServerPublishUrl
    $updateServer = nuget config DependencyManagementServerUpdateUrl
    if(!$server -or !$updateServer){ 
        Write-Host "Call Set-DependencyManagementServer [URL] before publishing or updating dependencies"
        throw "Dependency Management Server Source is not set."
    }
}

# Statement completion for project names
'Publish-Dependencies', 'Update-Dependencies', 'Get-DependencyManagementServer', 'Set-DependencyManagementServer' | %{ 
    Register-TabExpansion $_ @{
        ProjectName = { Get-Project -All | Select -ExpandProperty Name }
    }
}

Export-ModuleMember Publish-Dependencies, Update-Dependencies, Get-DependencyManagementServer, Set-DependencyManagementServer, Check-DependencyManagementServerExists