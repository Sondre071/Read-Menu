function Write-MenuTitle($Title, $TitleWidth) {
    $titleWithSpaces = " $Title "

    $paddingLength = [Math]::Max(0, ($TitleWidth - $titleWithSpaces.Length) / 2)
    $padding = '=' * [Math]::Floor($paddingLength)
    $line = "$padding$titleWithSpaces$padding"

    if ($line.Length -lt $TitleWidth) {
        $line += '='
    }

    Write-Host $line -ForegroundColor Yellow
}

function Exit-Menu($CleanUpAfter, $RowsToClear, $ClearFromRow) {
    if ($CleanUpAfter) {
        $FirstRow = if ($MenuTitle ) { $StartingRow - 1 } else { $StartingRow }

        [System.Console]::SetCursorPosition(0, $FirstRow)

        $TerminalWidth = [System.Console]::WindowWidth

        for ($i = 0; $i -lt $RowsToClear + 1; $i++) {
            Write-Host (' ' * $TerminalWidth)
        }

        [System.Console]::SetCursorPosition(0, $FirstRow)
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

        [string]$MenuTitle,

        [int]$TitleWidth = 30,

        [string]$MenuTextColor = 'Yellow',

        [switch]$CleanUpAfter
    )

    $CombinedOptions = @()

    if ($FirstOptions) { $CombinedOptions += $FirstOptions }
    if ($Options) { $CombinedOptions += $Options }
    if ($LastOptions) { $CombinedOptions += $LastOptions }
    if ($ExitOption) { $CombinedOptions += $ExitOption }

    $OptionsCount = $CombinedOptions.Count
    $HasTitle = -not [string]::IsNullOrWhiteSpace($MenuTitle)
    $TitleRowCount = if ($HasTitle) { 1 } else { 0 }
    $TotalMenuHeight = $OptionsCount + $TitleRowCount

    $CurrentIndex = 0
    $StartingRow = [System.Console]::CursorTop

    if ($HasTitle) {
        Write-MenuTitle -Title $MenuTitle -TitleWidth $TitleWidth
    }

    [System.Console]::CursorVisible = $False

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
                    Exit-Menu -CleanUpAfter $CleanUpAfter -ClearFromRow ($StartingRow - $TitleRowCount) -RowsToClear $TotalMenuHeight 

                    [System.Console]::CursorVisible = $true
                    Return $CombinedOptions[$CurrentIndex]
                }
                { $_ -in "Escape", "Q" -and $ExitOption } {
                    Exit-Menu -CleanUpAfter $CleanUpAfter -ClearFromRow ($StartingRow - $TitleRowCount) -RowsToClear $TotalMenuHeight 

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