if ($PSScriptRoot -ne '') {
    Push-Location $PSScriptRoot      # invoke-psake scheint nur im selben verzeichnis zu funktionieren
}

properties {
    $nameModule = (Split-Path $PSScriptRoot -Leaf)
    $dirProjectHome = $PSScriptRoot
    $dirModuleHome = "$dirProjectHome\$nameModule" 

    $testMessage = 'Executed Test!'
    $compileMessage = 'Executed Compile!'
    $cleanMessage = 'Executed Clean!'
    $helpMessage = 'You are asking for me master?'
    $srcPrivate = '.\Private'
    $srcPublic = '.\Public'
    $dirDocs = '.\docs'
    $dirDokuWiki = (Join-Path -Path $dirDocs -ChildPath "DokuWiki")
    $dirTests = '.\Tests'
}

task default -depends Test

task Test -depends Compile, Clean {
  # momentan geht der Remote-Test vonTest-RsReportDatasource.ps1 noch nicht
  # sonst sollten hier einfach alle Scrips ausgefuehrt werden
  $l = Get-ChildItem *.tests.ps1 -Recurse
  Invoke-Pester -Script $l -ExcludeTag Integration
} -description "Execute Pester tests"

task Compile -depends Clean {
    $compileMessage
}

task Clean {
    Remove-Module $nameModule -Force -ErrorAction SilentlyContinue
    $cleanMessage
}

task CreateDocs {
    Remove-Module -Name $nameModule -Force -ErrorAction SilentlyContinue
    Import-Module (Join-Path -Path $dirModuleHome -ChildPath "$nameModule.psm1") -Force
    Get-Command -Module $nameModule
    if (!(Test-Path -Path $dirDocs)) {
        New-Item -Path $dirDocs -ItemType Directory | Out-Null
        New-Item -Path $dirDokuWiki -ItemType Directory | Out-Null
    }
    Write-Verbose "New-MarkdownHelp -Module $nameModule -OutputFolder $dirDocs"
    New-MarkdownHelp -Module $nameModule -OutputFolder $dirDocs
    Write-Verbose "Update-MarkdownHelp -Path $dirDocs"   
    Update-MarkdownHelp -Path $dirDocs
} -description "Creates markdown help files and Dokuwiki style files"

task Build -depends Clean {
    $namePsd1 = "$dirModuleHome\$nameModule.psd1"
    $namePsm1 = "$dirModuleHome\$nameModule.psm1"
    Write-Verbose "Build: $nameModule, $dirProjectHome, $dirModuleHome, $srcPrivate, $srcPublic"
    Import-Module (Join-Path -Path $dirModuleHome -ChildPath "$nameModule.psd1") -Force
    $cmd = Get-Command -Module $nameModule
    $arr = $cmd | select -Property Name
    Write-Verbose $arr.Count
    if ( !($cmd.Count -gt 1) ) { Write-Error "Keine Commands exportiert" }
} -description "Build the module to be set to the repo"

task DeployIsa -depends Build {
    $namePsd1 = "$dirModuleHome\$nameModule.psd1"
    if ($null -eq $Env:IsaRepoApiKey) { Write-Error -Message "APIKey not set" -ErrorAction Stop }
    ###### Step 1: Increase minor release number in Manifest-File
    $Manifest = Import-PowerShellDataFile $namePsd1
    [version]$version = $Manifest.ModuleVersion
    # Add one to the build of the version number
    [version]$NewVersion = "{0}.{1}.{2}" -f $Version.Major, $Version.Minor, ($Version.Build + 1)
    # Update the manifest file, work around the problem, that is resets "FunctionsToExport" to defualt @()
    $cmd = Get-Command -Module $nameModule
    Update-ModuleManifest -Path $namePsd1 -ModuleVersion $NewVersion -FunctionsToExport $cmd.Name
    "New version: $NewVersion"

    ###### Step 2: Increase minor release number in Manifest-File
    Publish-Module -Path "$dirModuleHome" -Repository ISA -NuGetApiKey $Env:IsaRepoApiKey -Verbose
} -description "Deploy to our internal repository ISA"

task ? -Description "Helper to display task info" {
    $helpMessage
    "Possible tasks: default, Build, Clean, Compile, CreateDocs, DeployIsa"
}