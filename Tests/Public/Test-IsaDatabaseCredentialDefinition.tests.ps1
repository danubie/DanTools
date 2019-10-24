# . $PSScriptRoot\..\WWSpielwiese\Public\Test-IsaDatabaseCredentialDefinition.ps1
Remove-Module -Name IsaWebSqlToolbox -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\IsaWebSqlToolbox\IsaWebSqlToolbox.psm1

$dbUserList = @(
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db1';       Login = 'DOMAIN\User11';     AuthenticationType = 'Windows'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db1';       Login = 'DOMAIN\User12';     AuthenticationType = 'Windows'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db1';       Login = 'sqluser11';         AuthenticationType = 'SQL'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db1';       Login = 'sqluser12';         AuthenticationType = 'SQL'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db1';       Login = 'DOMAIN\User13';     AuthenticationType = 'Windows'   }
    #
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db2';       Login = 'DOMAIN\User11';     AuthenticationType = 'Windows'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db2';       Login = 'DOMAIN\User21';     AuthenticationType = 'Windows'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db2';       Login = 'DOMAIN\User22';     AuthenticationType = 'Windows'   }
    [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db2';       Login = 'sqluser21';         AuthenticationType = 'SQL'   }
    #
    [PSCustomObject]@{  InstanceName = 'Instance2';     Database = 'db3';       Login = 'DOMAIN\User11';     AuthenticationType = 'Windows'   }
)
$dbUserSingle =  [PSCustomObject]@{  InstanceName = 'Instance1';     Database = 'db1';       Login = 'DOMAIN\User11';     AuthenticationType = 'Windows'   }

Describe 'Test-IsaDatabaseCredentialDefinition@DB: ' {
    Context "Ich verwenden genau einen DBUser" {
        It "Check alle Attribute vorhanden" {
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InstanceName 'Instance1' -Database 'db1' -AccountName 'DOMAIN\User11'
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
        It "Check beliebige Datenbank soll OK sein" {
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InstanceName 'Instance1' -Database '*' -AccountName 'DOMAIN\User11'
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
        It "Username nicht gleich --> not valid" {
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InstanceName 'Instance1' -Database 'db1' -AccountName 'DOMAIN\Blabla'
            $result.AccountName | Should -Be 'DOMAIN\Blabla'
            $result.Isvalid | Should -BeFalse
        }
        It "Datenbankname nicht gleich --> not valid" {
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InstanceName 'Instance1' -Database 'blublu' -AccountName 'DOMAIN\User11'
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Database | Should -Be 'blublu'
            $result.Isvalid | Should -BeFalse
        }
        It "Instance nicht gleich --> not valid" {
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InstanceName 'blibli' -Database 'db1' -AccountName 'DOMAIN\User11'
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeFalse
        }
    }
}