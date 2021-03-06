---
external help file: DanTools-help.xml
Module Name: DanTools
online version:
schema: 2.0.0
---

# Test-IsaDatabaseCredentialDefinition

## SYNOPSIS
Tests if database users (coming from Get-DbaDBUsers) are in a "ok"-List, returns the a checked validation list

## SYNTAX

### ValidateOne
```
Test-IsaDatabaseCredentialDefinition -DbUser <Object[]> -InstanceName <String> -Database <String>
 -AccountName <String> [<CommonParameters>]
```

### ValidationList
```
Test-IsaDatabaseCredentialDefinition -DbUser <Object[]> -InputObject <Object[]> [<CommonParameters>]
```

## DESCRIPTION
Based on a definition list (Instance, DB, Account) all Windows-Logins are checked if the still should be allowed to access a database.
The validation list is returned with an additinal flag "IsValid". 
This flag can be checked to recognize outdated defintion objects.
"IsValid -eq $false" shows entries which do correspond to a user (anymore?).

## EXAMPLES

### BEISPIEL 1
```
$userList = Get-DbaDbUser -SqlInstance 'localhost:55555' -Database db1; $userChecked = Test-IsaDatabaseCredential -DBUser $userList -InstanceName 'Instance1' -Database 'db1' -AccountName 'DOMAIN\User11'
```

$validDefintions = $userChecked.Where({ $_.IsValid })
$outdatedDefintions = $userChecked.Where({ $_.IsValid -eq $false })
Checks for the presence of just one user definition

### BEISPIEL 2
```
$userList | Test-IsaDatabaseCredential -InputObject (Get-Content definition.csv | Convert-FromCsv )
```

Checks a user list (e.g.
from Get-DbaDbUser) against a validation list defined in a csv
The CSV must have the following form
InstanceName;Database;AccountName
Instance1;db1;DOMAIN\User1
Instance1;db1;DOMAIN\User2
Instance2;db1;DOMAIN\User3

## PARAMETERS

### -DbUser
List of user objects (like received from Get-DbaDbUser) to be validated. 
Of course One can use it's own object type.
The object has to have the following attributes (all of type string):
InstanceName    : Name of the database-instance
Database        : Name of the database
Login           : Login in form of 'DOMAIN\User11'
AuthenticationType = 'Windows'

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -InstanceName
Instance to which a Login is allowed to connect

```yaml
Type: String
Parameter Sets: ValidateOne
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Database
Database to which a Login is allowed to connect

```yaml
Type: String
Parameter Sets: ValidateOne
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AccountName
Windows Account allowed to connect

```yaml
Type: String
Parameter Sets: ValidateOne
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -InputObject
List of hashtable containing the definition of the valid instance/db/userlogin pairs

```yaml
Type: Object[]
Parameter Sets: ValidationList
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
General notes

## RELATED LINKS
