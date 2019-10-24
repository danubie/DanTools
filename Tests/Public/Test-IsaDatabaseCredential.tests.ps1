# . $PSScriptRoot\..\WWSpielwiese\Public\Test-IsaDatabaseCredential.ps1
Remove-Module -Name IsaWebSqlToolbox -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot\..\..\DanTools\DanTools.psm1

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

Describe 'Test-IsaDatabaseCredential@DB: ' {
    Context "Ich verwenden genau einen DBUser" {
        It "Check alle Attribute vorhanden" {
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InstanceName 'Instance1' -Database 'db1' -AccountName 'DOMAIN\User11'
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
        It "Check beliebige Datenbank soll OK sein" {
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InstanceName 'Instance1' -Database '*' -AccountName 'DOMAIN\User11'
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
        It "Username nicht gleich --> not valid" {
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InstanceName 'Instance1' -Database 'db1' -AccountName 'DOMAIN\Blabla'
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeFalse
        }
        It "Datenbankname nicht gleich --> not valid" {
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InstanceName 'Instance1' -Database 'blublu' -AccountName 'DOMAIN\User11'
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeFalse
        }
        It "Instance nicht gleich --> not valid" {
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InstanceName 'blibli' -Database 'db1' -AccountName 'DOMAIN\User11'
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeFalse
        }
    }
    Context "über Input-Object prüfen" {
        It "Check alle Attribute vorhanden" {
            $zuPruefen = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\User11' }
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InputObject $zuPruefen
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
        It "Check beliebige Datenbank soll OK sein" {
            $zuPruefen = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = '*'; AccountName = 'DOMAIN\User11' }
            $result = Test-IsaDatabaseCredential -DbUser $dbUserSingle -InputObject $zuPruefen
            $result.Login | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
    }
}