# DanTools
## about_DanTools

# SHORT DESCRIPTION
This module is a collection of small functions which i use in a daily routine.
It was created as my first contribution to the github community

# LONG DESCRIPTION
Welcome to DanTools overview.

The following functions are available

## Get-IsaCredential
Small enhancment to Get-Credential which allows to tell computername to validate the credentials

## Show-CmdletOfTheDay
A function to randomly select a command from your installed modules.
Displays a compact help. Allows to learn about commands you otherwise would not recoginize.

## Test-IsaDatabaseCredential
The function accepts a list of objects which define AD-accounts which  are allowed to have access to a database. This list is used to validate objects of database users (e.g. coming from lovely @dbatools Get-DbDatabaseUser).

## Test-IsaDatabaseCredentialDefinition
The function is "the opposite" of "Test-IsaDatabaseCredential". It checks if the entries in the AD-accounts list are still up-to-date. If a entry is not seen in any of the database user objects, it will get a flag "not valid".

# KEYWORDS
- Tools
- DB access validation
