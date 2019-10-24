<#
.SYNOPSIS
Checks database users (coming from Get-DbaDBUsers) are still valid

.DESCRIPTION
Based on a definition list (Instance, DB, Account) alle Windows-Logins are checked if the still should be allowed to access a database.
A list is returned and each inpu user object receives a flag "IsValid" to indicate that this account was found based on the conditions of the validation list.

.PARAMETER DbUser
List of user objects (like received from Get-DbaDbUser) to be validated. 
Of course One can use it's own object type. The object has to have the following attributes (all of type string):
InstanceName    : Name of the database-instance
Database        : Name of the database
Login           : Login in form of 'DOMAIN\User11'
AuthenticationType = 'Windows'

.PARAMETER InstanceName
Instance to which a Login is allowed to connect

.PARAMETER Database
Database to which a Login is allowed to connect

.PARAMETER AccountName
Windows Account allowed to connect

.PARAMETER InputObject
List of hashtable containing the definition of the valid instance/db/userlogin pairs

.EXAMPLE
$userList = Get-DbaDbUser -SqlInstance 'localhost:55555' -Database db1; $userChecked = Test-IsaDatabaseCredential -DBUser $userList -InstanceName 'Instance1' -Database 'db1' -AccountName 'DOMAIN\User11'
$valid = $userChecked.Where({ $_.IsValid})
Checks for the presence of just one user definition

.EXAMPLE
$userList | Test-IsaDatabaseCredential -InputObject (Get-Content definition.csv | Convert-FromCsv )
Checks a user list (e.g. from Get-DbaDbUser) against a validation list defined in a csv
The CSV must have the following form
InstanceName;Database;AccountName
Instance1;db1;DOMAIN\User1
Instance1;db1;DOMAIN\User2
Instance2;db1;DOMAIN\User3

.NOTES
General notes
#>
function Test-IsaDatabaseCredential {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        HelpMessage="Liste der Berechtigungen in der Datenbank.")]
        [ValidateNotNullOrEmpty()]
        [Object[]] $DbUser,
        [Parameter(Mandatory=$true,
                   ParameterSetName= 'ValidateOne',
                   HelpMessage="Name der Instanz auf die eine Berechtigung erteilt ist.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $InstanceName,
        [Parameter(Mandatory=$true,
                   ParameterSetName= 'ValidateOne',
                   HelpMessage="Name der Datenbank auf die eine Berechtigung erteilt ist.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $Database,
        [Parameter(Mandatory=$true,
                   ParameterSetName= 'ValidateOne',
                   HelpMessage="Name des ADAccounts für den eine Berechtigung erteilt ist.")]
        [ValidateNotNullOrEmpty()]
        [string]
        $AccountName,
        [Parameter(Mandatory=$true,
                   ParameterSetName= 'ValidationList',
                   HelpMessage="Name des ADAccounts für den eine Berechtigung erteilt ist.")]
        [ValidateNotNullOrEmpty()]
        [Object[]]
        $InputObject
    )
    BEGIN {
        # zur Vereinfachung: Bei Parameterset "ValidateOne" bau ich ein passendes InputObject zusammen
        # vereinfacht den Code dramatisch
        if ($null -eq $InputObject) {
            $InputObject = [PSCustomObject]@{
                InstanceName = $InstanceName
                Database     = $Database
                AccountName  = $AccountName                
            }
        }
    }
    PROCESS {
        foreach ($currDbUser in $DbUser) {
            if ($null -eq $currDbUser.IsValid) { Add-member -InputObject $currDbUser -Name "IsValid" -Value $false -MemberType NoteProperty }
            $currDbUser.IsValid = $false
            foreach ($obj in $InputObject) {
                if ( $obj.Database -eq '*' ) {
                    if ( ($currDbUser.InstanceName -eq $obj.InstanceName) -and ($currDbUser.Login -eq $obj.AccountName) -and ($currDbUser.AuthenticationType -eq 'Windows') ) {
                        $currDbUser.IsValid = $true
                    }
                } else {
                    if ( ($currDbUser.InstanceName -eq $obj.InstanceName) -and ($currDbUser.Database -eq $obj.Database) -and ($currDbUser.Login -eq $obj.AccountName) -and ($currDbUser.AuthenticationType -eq 'Windows') ) {
                        $currDbUser.IsValid = $true
                    }
                }
            }
            $currDbUser
        }
    }
    END {}
}