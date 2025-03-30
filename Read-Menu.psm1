function Write-MenuTitle($MenuTitle, $MenuTitleWidth = 40) {
    $titleWithSpaces = " $MenuTitle "

    $paddingLength = [Math]::Max(0, ($MenuTitleWidth - $titleWithSpaces.Length) / 2)
    $padding = '=' * [Math]::Floor($paddingLength)
    $line = "$padding$titleWithSpaces$padding"

    if ($line.Length -lt $MenuTitleWidth) {
        $line += '='
    }

    Write-Host $line -ForegroundColor Yellow
}

function Exit-Menu($CleanUpAfter, $RowsToClear, $ClearFromRow) {
    if ($CleanUpAfter) {
        [System.Console]::SetCursorPosition(0, $ClearFromRow)

        $TerminalWidth = [System.Console]::WindowWidth

        for ($i = 0; $i -lt $RowsToClear; $i++) {
            Write-Host (' ' * $TerminalWidth)
        }

        [System.Console]::SetCursorPosition(0, $ClearFromRow)
    }
    else {
        Write-Host
    }
}

function Read-Menu {
    param (
        [string[]]$Options,

        [string]$ExitOption,

        [string]$MenuTitle,

        [int]$MenuTitleWidth = 40,

        [string]$MenuTextColor = 'Yellow',

        [switch]$CleanUpAfter
    )

    $CombinedOptions = @()

    if ($Options) { $CombinedOptions += $Options }
    if ($ExitOption) { $CombinedOptions += $ExitOption }

    $OptionsCount = $CombinedOptions.Count
    $HasTitle = -not [string]::IsNullOrWhiteSpace($MenuTitle)
    $TitleRowCount = if ($HasTitle) { 1 } else { 0 }
    $TotalMenuHeight = $OptionsCount + $TitleRowCount

    $CurrentIndex = 0
    $StartingRow = [System.Console]::CursorTop

    if ($HasTitle) {
        Write-MenuTitle -MenuTitle $MenuTitle -MenuTitleWidth $MenuTitleWidth
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
                    Return $ExitOption
                }
            }
        }

        $StartingRow = [System.Console]::CursorTop - $OptionsCount
        [System.Console]::SetCursorPosition(0, $StartingRow)
    }
}

function Read-Input() {
    param (
        [string]$Instruction = 'You',
        [string]$MenuTitle,
        [int]$MenuTitleWidth = 40,
        [switch]$CleanUpAfter
    )

    $StartingRow = [System.Console]::CursorTop

    Write-MenuTitle -MenuTitle $MenuTitle -MenuTitleWidth $MenuTitleWidth

    $userInput = Read-Host $Instruction

    $CurrentRow = [System.Console]::CursorTop
    $RowsToClear = $CurrentRow - $StartingRow

    Exit-Menu -CleanUpAfter $CleanUpAfter -RowsToClear $RowsToClear -ClearFromRow $StartingRow

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuTitle