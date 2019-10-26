<#
.SYNOPSIS
    Gets credential but check password against a computer
    (c) 2018 Wolfgang Wagner
.DESCRIPTION
    This is just Get-Credential but you can specify a Computername.
    Then the credentials are used to start a remote-session to verify your passwort
.PARAMETER DomainName
    Name of the Domain
.PARAMETER ComputerName
    Name of the computer to test against
.PARAMETER Message
    Credential message
.PARAMETER userName
    Username (Default: current user $env:Username)
.OUTPUTS
    System.Management.Automation.PSCredential
    Credential for the current user in the specified AD-Domain.
.EXAMPLE
    Get-IsaCredential -Domainname DOM1
    Returns a credential for user <DOM1\>
.EXAMPLE
    Get-IsaCredential -Domainname DOM1 -message "Dies ist die Überschrift"
    Header für the Password prompt
.EXAMPLE
    Get-IsaCredential -Domainname DOM2 -userName "TheUser"
    Returns a credential for user <DOM2\TheUser> or if not cached prompts for it
.EXAMPLE
    Get-IsaCredential -Domainname DOM2 -userName "TheUser" -Force
    Prompts and returns credentials for user <DOM2\TheUser>
.EXAMPLE
    Get-IsaCredential -Computername "server.DOM.something" -userName "TheUser" -Force
    Prompts and returs credentials for user <DOM\TheUser>, stores the Credentuals in a variable
    and checks the credentials through trying to connect to the server
#>
function Get-IsaCredential {
    [CmdletBinding()]
    param (
        [string] $DomainName = $env:USERDOMAIN,
        [string] $Message,
        [string] $UserName = $env:USERNAME,
        [parameter(ParameterSetName='ComputerName',Mandatory=$true)]
        [string] $ComputerName
    )
    $admLoginName = "$DomainName\$($UserName)"
    if ( ($null -eq $Message) -or ($Message -eq '') ) {
        $Message = 'Please enter your password'
    }
    $cred = Get-Credential -UserName $admLoginName -Message $Message
    if ( $ComputerName -ne '' ) {
        $answer = Invoke-Command -ComputerName $ComputerName -Credential $cred -ScriptBlock { "huihui" }
        if ( $answer -eq 'huihui' ) {
            $cred
        } else {
            Write-Warning "invalid user or password"
        }
    } else {
        $cred
    }
}
