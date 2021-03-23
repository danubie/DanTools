Remove-Module -Name DanTools -Force -ErrorAction SilentlyContinue
Import-Module $PSScriptRoot/../../DanTools/DanTools.psm1

BeforeAll {
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
}
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
    Context "über Input-Object prüfen" {
        It "Check alle Attribute vorhanden" {
            $zuPruefen = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\User11' }
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InputObject $zuPruefen
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
        It "Check beliebige Datenbank soll OK sein" {
            $zuPruefen = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = '*'; AccountName = 'DOMAIN\User11' }
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InputObject $zuPruefen
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
    }
    Context "über Liste von Input-Object prüfen" {
        It "Check alle Attribute vorhanden: Single User" {
            $zuPruefen = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\User11' }
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserSingle -InputObject $zuPruefen
            $result.AccountName | Should -Be 'DOMAIN\User11'
            $result.Isvalid | Should -BeTrue
        }
    }
    Context "Große Liste an DBUsern" {
        It "2 gueltig; Rest ungueltig" {
            $zuPruefen1 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\User11' }
            $zuPruefen2 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db2'; AccountName = 'DOMAIN\User21' }
            $zuPruefen3 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\huhu' }
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserList -InputObject ($zuPruefen1,$zuPruefen2,$zuPruefen3)
            $result.Count | Should -Be 3
            $valid = $result.Where({ $_.Isvalid })
            $valid.Count        | Should -Be 2
            $valid[0].AccountName     | Should -Be 'DOMAIN\User11'
            $valid[0].Database  | Should -Be 'db1'
            $valid[1].AccountName     | Should -Be 'DOMAIN\User21'
            $valid[1].Database  | Should -Be 'db2'
        }
        It "User11 in 3 DBs, User12 in 1 DB" {
            $zuPruefen1 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = '*';   AccountName = 'DOMAIN\User11' }
            $zuPruefen2 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\User12' }
            $zuPruefen3 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\huhu' }
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserList -InputObject ($zuPruefen1,$zuPruefen2,$zuPruefen3)
            $result.Count | Should -Be 3
            $valid = $result.Where({ $_.Isvalid })
            $valid.Count        | Should -Be 2
            $valid[0].AccountName     | Should -Be 'DOMAIN\User11'
            $valid[0].Database  | Should -Be '*'
            $valid[1].AccountName     | Should -Be 'DOMAIN\User12'
            $valid[1].Database  | Should -Be 'db1'
        }
        It "keiner von den drei erlaubten trifft zu: 0 valid" {
            $zuPruefen1 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\hoho' }
            $zuPruefen2 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = '*';   AccountName = 'DOMAIN\haha' }
            $result = Test-IsaDatabaseCredentialDefinition -DbUser $dbUserList -InputObject ($zuPruefen1,$zuPruefen2)
            $result.Count       | Should -Be 2
            $valid = $result.Where({ $_.Isvalid })
            $valid              | Should -BeNullOrEmpty
        }
    }
    Context "Pipeline direkt" {
        It "3 erlaubte; aber nur 1 kommt zurück (Verena)" {
            $zuPruefen1 = [PSCustomObject] @{ InstanceName = 'Instance1'; Database = 'db1'; AccountName = 'DOMAIN\hoho' }
            $zuPruefen2 = [PSCustomObject] @{ InstanceName = 'Instance2'; Database = 'db3'; AccountName = 'DOMAIN\User11' }
            $result = $dbUserList   | Test-IsaDatabaseCredentialDefinition -InputObject ($zuPruefen1,$zuPruefen2)
            $result[0].AccountName     | Should -Be 'DOMAIN\hoho'
            $result[0].Database        | Should -Be 'db1'
            $result[0].InstanceName    | Should -Be 'Instance1'
            $result[0].Isvalid          | Should -Be $false
            $result[1].AccountName     | Should -Be 'DOMAIN\User11'
            $result[1].Database        | Should -Be 'db3'
            $result[1].InstanceName    | Should -Be 'Instance2'
            $result[1].Isvalid          | Should -Be $true
        }
    }
}