function Write-MenuHeader($Header, $HeaderWidth = 40) {
    $headerWithSpaces = " $Header "

    $paddingLength = [Math]::Max(0, ($HeaderWidth - $headerWithSpaces.Length) / 2)
    $padding = '=' * [Math]::Floor($paddingLength)
    $line = "$padding$headerWithSpaces$padding"

    if ($line.Length -lt $HeaderWidth) {
        $line += '='
    }

    Write-Host $line -ForegroundColor Yellow
}

function Exit-Menu($ClearFromRow, $RowsToClear, $CleanUpAfter) {
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

        [string]$Header,

        [int]$HeaderWidth = 40,

        [string[]]$Subheader,

        [string]$MenuTextColor = 'Yellow',

        [switch]$CleanUpAfter
    )

    $CombinedOptions = @()

    if ($Options) { $CombinedOptions += $Options }
    if ($ExitOption) { $CombinedOptions += $ExitOption }

    $CombinedOptionsCount = $CombinedOptions.Count
    $HasHeader = -not [string]::IsNullOrWhiteSpace($Header)
    $HasSubheader = $Subheader -gt 0

    $HeaderRowCount = 0

    if ($HasHeader) { $HeaderRowCount++ }
    if ($HasSubheader) { $HeaderRowCount += $Subheader.Count }

    $TotalMenuHeight = $CombinedOptionsCount + $HeaderRowCount

    if ($HasHeader) {
        Write-MenuHeader -Header $Header -HeaderWidth $HeaderWidth
    }

    if ($HasSubheader) {
        $Subheader | ForEach-Object { Write-Host $_ -ForegroundColor $MenuTextColor }
    }

    $CurrentIndex = 0
    $StartingRow = [System.Console]::CursorTop

    [System.Console]::CursorVisible = $False

    while ($true) {
        for ($i = 0; $i -lt $CombinedOptionsCount; $i++) {
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
                    $CurrentIndex = [Math]::Min($CombinedOptionsCount - 1, $CurrentIndex + 1)
                    Break
                }
                { $_ -in "Enter", "L" } {
                    Exit-Menu -CleanUpAfter $CleanUpAfter -ClearFromRow ($StartingRow - $HeaderRowCount) -RowsToClear $TotalMenuHeight 

                    [System.Console]::CursorVisible = $true
                    Return $CombinedOptions[$CurrentIndex]
                }
                { $_ -in "Escape", "Q" -and $ExitOption } {
                    Exit-Menu -CleanUpAfter $CleanUpAfter -ClearFromRow ($StartingRow - $HeaderRowCount) -RowsToClear $TotalMenuHeight 

                    [System.Console]::CursorVisible = $true
                    Return $ExitOption
                }
            }
        }

        $StartingRow = [System.Console]::CursorTop - $CombinedOptionsCount
        [System.Console]::SetCursorPosition(0, $StartingRow)
    }
}

function Read-Input() {
    param (
        [string]$Header,
        [int]$HeaderWidth = 40,
        [string[]]$Subheader,
        [string]$Instruction = 'You',
        [switch]$CleanUpAfter
    )

    $StartingRow = [System.Console]::CursorTop

    if ($Header) { Write-MenuHeader -Header $Header -HeaderWidth $HeaderWidth }
    if ($Subheader) { $Subheader | ForEach-Object { Write-Host $_ -ForegroundColor $MenutextColor } }

    $userInput = Read-Host $Instruction

    $CurrentRow = [System.Console]::CursorTop
    $RowsToClear = $CurrentRow - $StartingRow

    Exit-Menu -ClearFromRow $StartingRow -RowsToClear $RowsToClear -CleanUpAfter $CleanUpAfter 

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuHeader