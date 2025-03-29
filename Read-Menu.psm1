function Read-Menu {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$Options,

        [string[]]$FirstOptions,

        [string[]]$LastOptions,

        [string]$ExitOption,

        [switch]$SkipSorting,

        [string]$MenuTextColor = 'Yellow'
    )

    if (-not $SkipSorting) {
        $Options = $Options | Sort-Object
    }

    if ($FirstOptions) { $Options = $FirstOptions + $Options }
    if ($LastOptions) { $Options += $LastOptions }
    if ($ExitOption) { $Options += $ExitOption }

    [System.Console]::CursorVisible = $False

    $CurrentIndex = 0
    $StartingRow = [System.Console]::CursorTop

    while ($true) {
        for ($i = 0; $i -lt $Options.Count; $i++) {
            $color = if ($i -eq $CurrentIndex) { $MenuTextColor } else { 'Gray' }
            Write-Host ">  $($Options[$i])" -ForegroundColor $color
        }

        if ([Console]::KeyAvailable) {
            $keyInfo = [Console]::ReadKey($true)

            switch ($keyInfo.Key) {
                { $_ -in "UpArrow", "K" } {
                    $CurrentIndex = [Math]::Max(0, $CurrentIndex - 1)
                    Break
                }
                { $_ -in "DownArrow", "J" } {
                    $CurrentIndex = [Math]::Min($Options.Count - 1, $CurrentIndex + 1)
                    Break
                }
                { $_ -in "Enter", "L" } {
                    [System.Console]::CursorVisible = $true
                    Return $Options[$CurrentIndex]
                }
                { $_ -in "Escape", "Q" -and $ExitOption } {
                    [System.Console]::CursorVisible = $true
                    Return 'Exit'
                }
            }
        }

        $StartingRow = [System.Console]::CursorTop - $Options.Length
        [System.Console]::SetCursorPosition(0, $StartingRow)
    }
}

Export-ModuleMember -Function Read-Menu