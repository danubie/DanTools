<#
.SYNOPSIS
    Ein bisserl bequemer Admin-Credentials erfragen
    (c) 2018 Wolfgang Wagner
.DESCRIPTION
    Die Regel der Inhouse ist: Username --> adm_Username in den entsprechenden AD-Domains
    Das Ergebnis wird in einer Variablen gecached, die man direkt weiterverwenden kann.
    Z.B. für die Domäne DOM wird eine Variable DOMadm angelegt mit den Credentials für DOM\adm_username
.PARAMETER DomainName
    Name der AD-Domain für die der Admin-Account gebraucht wird
.PARAMETER ComputerName
    Name eines Servers zu dessen Domain ein Account gesucht wird. Bsp. == DOMAIN bei "servername.DOMAIN.wasauchimmer"
.PARAMETER Message
    Text, der in der Abfrage der Credentials als Prompt angezeigt wird
.PARAMETER userName
    Username, der verwendet werden soll (Default: Aktueller Benuter - $env:Username)
.PARAMETER Scope
    Scope, in dem die Variable (DOMAINadm) mit den Credentials angelegt werden sol
.PARAMETER Force
    Eine eventuell bestehende Variable wird gelöscht und das PW neu angefordert.
.OUTPUTS
    System.Management.Automation.PSCredential
    Admin-Credential for the current user in the specified AD-Domain.
.EXAMPLE
    Get-IsaAdminCredential -Domainname WEB
    Returns a credential for user <WEB\adm_CrrentUser>
.EXAMPLE
    Get-IsaAdminCredential -Domainname WEB -message "Dies ist die Überschrift"
    Header für the Password prompt
.EXAMPLE
    Get-IsaAdminCredential -Domainname WKOE -userName "TheAdmin"
    Returns a credential for user <WKOE\adm_TheAdmin> or if not cached prompts for it
.EXAMPLE
    Get-IsaAdminCredential -Domainname WKOE -userName "TheAdmin" -Force
    Prompts and returns credentials for user <WKOE\adm_TheAdmin>
.EXAMPLE
    Get-IsaAdminCredential -Computername "server.DOM.something" -userName "TheAdmin" -Force
    Prompts and returs credentials for user <DOM\adm_TheAdmin>, stores the Credentuals in a variable
    and checks the credentials through trying to connect to the server
#>
function Get-IsaAdminCredential {
    [CmdletBinding()]
    param (
        [string] $DomainName = $env:USERDOMAIN,
        [string] $Message,
        [string] $UserName = $env:USERNAME
    )
    $admLoginName = "$DomainName\adm_$($UserName)"
    if ( ($null -eq $Message) -or ($Message -eq '') ) {
        $Message = 'Please enter your password'
    }
    $cred = Get-Credential -UserName $admLoginName -Message $Message
    $cred
}
