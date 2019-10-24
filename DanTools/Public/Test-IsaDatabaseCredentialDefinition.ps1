function Test-IsaDatabaseCredentialDefinition {
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
        $InputObject.ForEach( {Add-member -InputObject $_ -Name "IsValid" -Value $false -MemberType NoteProperty} )
    }
    PROCESS {
        foreach ($currDbUser in $DbUser) {
            foreach ($obj in $InputObject) {
                if ( $obj.Database -eq '*' ) {
                    if ( ($currDbUser.InstanceName -eq $obj.InstanceName) -and ($currDbUser.Login -eq $obj.AccountName) -and ($currDbUser.AuthenticationType -eq 'Windows') ) {
                        $obj.IsValid = $true
                    }
                } else {
                    if ( ($currDbUser.InstanceName -eq $obj.InstanceName) -and ($currDbUser.Database -eq $obj.Database) -and ($currDbUser.Login -eq $obj.AccountName) -and ($currDbUser.AuthenticationType -eq 'Windows') ) {
                        $obj.IsValid = $true
                    }
                }
            }
        }
    }
    END {
        Write-Output $InputObject
    }
}