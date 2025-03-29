function Exit-Menu($CleanUpAfter, $MenuHeight, $StartingRow) {
    if ($CleanUpAfter) {
        [System.Console]::SetCursorPosition(0, $StartingRow)

        $TerminalWidth = [System.Console]::WindowWidth

        for ($i = 0; $i -lt $MenuHeight + 1; $i++) {
            Write-Host (' ' * $TerminalWidth)
        }

        [System.Console]::SetCursorPosition(0, $StartingRow)
    }
    else {
        Write-Host
    }
}

function Read-Menu {
    param (
        [string[]]$Options,

        [string[]]$FirstOptions,

        [string[]]$LastOptions,

        [string]$ExitOption,

        [switch]$CleanUpAfter,

        [string]$MenuTextColor = 'Yellow'
    )

    $CombinedOptions = @()

    if ($FirstOptions) { $CombinedOptions += $FirstOptions }
    if ($Options) { $CombinedOptions += $Options }
    if ($LastOptions) { $CombinedOptions += $LastOptions }
    if ($ExitOption) { $CombinedOptions += $ExitOption }

    $OptionsCount = $CombinedOptions.Count

    [System.Console]::CursorVisible = $False

    $CurrentIndex = 0
    $StartingRow = [System.Console]::CursorTop

    while ($true) {
        for ($i = 0; $i -lt $OptionsCount; $i++) {
            $color = if ($i -eq $CurrentIndex) { $MenuTextColor } else { 'Gray' }
            Write-Host ">  $($CombinedOptions[$i])" -ForegroundColor $color
        }

        if ([Console]::KeyAvailable) {
            $keyInfo = [Console]::ReadKey($true)

            switch ($keyInfo.Key) {
                { $_ -in "UpArrow", "K" } {
                    $CurrentIndex = [Math]::Max(0, $CurrentIndex - 1)
                    Break
                }
                { $_ -in "DownArrow", "J" } {
                    $CurrentIndex = [Math]::Min($OptionsCount - 1, $CurrentIndex + 1)
                    Break
                }
                { $_ -in "Enter", "L" } {
                    Exit-Menu -CleanUpAfter $CleanUpAfter -MenuHeight $OptionsCount -StartingRow $StartingRow

                    [System.Console]::CursorVisible = $true
                    Return $CombinedOptions[$CurrentIndex]
                }
                { $_ -in "Escape", "Q" -and $ExitOption } {
                    Exit-Menu -CleanUpAfter $CleanUpAfter -MenuHeight $OptionsCount -StartingRow $StartingRow

                    [System.Console]::CursorVisible = $true
                    Return 'Exit'
                }
            }
        }

        $StartingRow = [System.Console]::CursorTop - $OptionsCount
        [System.Console]::SetCursorPosition(0, $StartingRow)
    }
}

Export-ModuleMember -Function Read-Menu