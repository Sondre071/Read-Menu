function Get-Options {
    [OutputType([object[]])]
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