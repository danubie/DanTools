<#
.SYNOPSIS
    Gibt eine Kurzfassung der Hilfe eines Commandlets aus
    (c) 2018-2019 Wolfgang Wagner
.DESCRIPTION
    Es wird eine Art "get-help" einer zufällig ausgewählten Funktion od. Commandlet augegeben
.PARAMETER Module
    Liste von Modulnamen, die durchsucht werden sollen (Default: alle Module)
.PARAMETER CommandType
    Was soll ausgewählt werden: CmdLets, Functions, Workflows, ... siehe Hilfe von Get-Command
    Default: Cmdlet, Function
.OUTPUTS
    Excerpt der Hilfe eines Commands (mit Write-Host)
.EXAMPLE
    Show-CmdletOfTheDay
    Zeigt ein Command aus allen Modulen
.EXAMPLE
    PS C:> Show-CmdletOfTheDay 'NetTCPIP'
    Es werden nur Functions bzw. CmdLets des Moduls 'NetTCPIP' geliefrt (z.B. GetNetIPAdress)
.EXAMPLE
    PS C:> Show-CmdletOfTheDay -Module 'NetTCPIP','DnsClient' -CommandType 'Cmdlet'
    Es werden ausschließlich Commandlets geliefert (in diesem Beispiel kann nur "Resolve-DnsName" als Ergebnis kommen)
.NOTES
    Original https://gallery.technet.microsoft.com/scriptcenter/Powershell-Cmdlet-of-the-ac60c293

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
