function Get-MenuOptions {
    param (
        [Parameter(Mandatory)]
        [object[]]$Options,
        [object]$ExitOption
    )
    $combinedOptions = @()

    if ($Options) { $combinedOptions += $Options }
    if ($ExitOption) { $combinedOptions += $ExitOption }

    return $combinedOptions
}