Write-Verbose "psm1 Script-Root: $PSScriptRoot"
$private = Get-ChildItem (Join-Path $PSScriptRoot "Private") -Recurse -Filter '*.ps1'
$public = Get-ChildItem (Join-Path $PSScriptRoot "Public") -Recurse -Filter '*.ps1'
foreach ($function in $private) {
    . $function.FullName
    Write-Verbose "Include private: $($function.FullName)"
}
foreach ($function in $public) {
    . $function.FullName
    Write-Verbose "Include public: $($function.FullName)"
}

Export-ModuleMember -Function $public.BaseName -Verbose
