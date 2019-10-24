<#
.SYNOPSIS
    Shows a short description of the command based help
    (c) 2018-2019 Wolfgang Wagner
.DESCRIPTION
    This commandlet selects a random module and function. 
    A part of the "ge-help" output of this selected function or cmdlet is the result of this script 
.PARAMETER Module
    List of modulenames to be used for selecting the randomized function (default: all modules) 
.PARAMETER CommandType
    Type of what should be selected: CmdLets, Functions, Workflows, ... see help of Get-Command
    Default: Cmdlet, Function
.OUTPUTS
    Excerpt of the command based help of the selected command (mit Write-Host)
.EXAMPLE
    Show-CmdletOfTheDay
    Shows the short description of a function out of all modules installed
.EXAMPLE
    PS C:> Show-CmdletOfTheDay 'NetTCPIP'
    Only functions of the addressed module 'NetTCPIP' are candidates to be selected (e.g. GetNetIPAdress)
.EXAMPLE
    PS C:> Show-CmdletOfTheDay -Module 'NetTCPIP','DnsClient' -CommandType 'Cmdlet'
    Returns cmdlets of the selected modules only  (e.g. "Resolve-DnsName" will be the only result)
.NOTES
    The original function was published at https://gallery.technet.microsoft.com/scriptcenter/Powershell-Cmdlet-of-the-ac60c293
    This version includes some enhancements and error corrections
#>
Function Show-CmdletOfTheDay
{
    [CmdletBinding()]
    param (
        [string[]]
        $Module = "",
        [string[]]
        $CommandType = @('Function','Cmdlet')
    )

    $FilenameDesc = "$env:TEMP\COTDDescription.txt"
    $FileNameExample = "$env:TEMP\COTDExample.txt"
    Function Get-HelpDescription ($d)
    {
        $help.description|Out-File $FilenameDesc
        $Description=@()
        ((Get-Content $FilenameDesc)|Where-Object{$_ -ne ''})| ForEach-Object {$Description+="$($_.trim())`n"}
        return $Description
    }

    Function Get-HelpExample ($e)
    {
        $e | Out-File $FileNameExample
        $examples=@()
        $Content = (Get-Content $FileNameExample)|Where-Object{$_ -ne ''}
        For($i = 1; $i -le $Content.count; $i++)
        {
            if($Content[$i] -like '*EXAMPLE 1*' -or $Content[$i] -like '*Example 1*')
            {$examples+=""}
            elseif($Content[$i] -like '*EXAMPLE 2*' -or $Content[$i] -like '*Example 2*')
            {return $examples}
            elseif($i -eq $Content.count)
            {return $examples}
            else
            {$examples+="$($content[$i])`n"}
        }
    }

    #Cls
    # Title in the PowerShell Console
    Write-Host "`nHere is your #PSCmdlet of the Day`n`n" -ForegroundColor Yellow

    # Choosing a Random Powershell Cmdlet
    $prop = @{
        Module = $Module
        CommandType = $CommandType
    }
    $RandomCmdlet = Get-Command * @prop | Get-Random
    $help = Get-Help $RandomCmdlet.Name -Full

    # To Generate the Display
    Write-Host "NAME" -ForegroundColor Yellow
    Write-host " $($help.Name)"
    Write-Host "SYNOPSIS"  -ForegroundColor Yellow
    Write-host " $($help.Synopsis)"
    Write-host "DESCRIPTION" -ForegroundColor Yellow
    Write-host " $(Get-HelpDescription $help.description)"
    Write-host "EXAMPLE" -ForegroundColor Yellow
    Write-host " $(Get-HelpExample $help.examples)"

    Remove-Item $FilenameDesc, $FileNameExample
    Remove-Variable Help, RandomCmdlet
}
