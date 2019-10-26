---
external help file: DanTools-help.xml
Module Name: DanTools
online version:
schema: 2.0.0
---

# Show-CmdletOfTheDay

## SYNOPSIS
Shows a short description of the command based help

## SYNTAX

```
Show-CmdletOfTheDay [[-Module] <String[]>] [[-CommandType] <String[]>] [<CommonParameters>]
```

## DESCRIPTION
This commandlet selects a random module and function. 
A part of the "ge-help" output of this selected function or cmdlet is the result of this script

## EXAMPLES

### BEISPIEL 1
```
Show-CmdletOfTheDay
```

Shows the short description of a function out of all modules installed

### BEISPIEL 2
```
Show-CmdletOfTheDay 'NetTCPIP'
```

Only functions of the addressed module 'NetTCPIP' are candidates to be selected (e.g.
GetNetIPAdress)

### BEISPIEL 3
```
Show-CmdletOfTheDay -Module 'NetTCPIP','DnsClient' -CommandType 'Cmdlet'
```

Returns cmdlets of the selected modules only  (e.g.
"Resolve-DnsName" will be the only result)

## PARAMETERS

### -Module
List of modulenames to be used for selecting the randomized function (default: all modules)

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandType
Type of what should be selected: CmdLets, Functions, Workflows, ...
see help of Get-Command
Default: Cmdlet, Function

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: @('Function','Cmdlet')
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### Excerpt of the command based help of the selected command (mit Write-Host)
## NOTES
The original function was published at https://gallery.technet.microsoft.com/scriptcenter/Powershell-Cmdlet-of-the-ac60c293
This version includes some enhancements and error corrections

## RELATED LINKS
