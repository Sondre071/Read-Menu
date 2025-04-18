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

function Exit-Menu($TotalMenuHeight, $CleanUpAfter) {
    if ($CleanUpAfter) {

        # Jump $TotalMenuHeight lines up and clear everything below.
        Write-Host "$([char]27)[$($TotalMenuHeight)A" -NoNewLine
        Write-Host "$([char]27)[0J" -NoNewLine
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

    $combinedOptions = @()

    if ($Options) { $CombinedOptions += $Options }
    if ($ExitOption) { $CombinedOptions += $ExitOption }

    $hasHeader = -not [string]::IsNullOrWhiteSpace($Header)
    $hasSubheader = $Subheader -gt 0

    $headerRowCount = 0

    if ($hasHeader) { $headerRowCount++ }
    if ($hasSubheader) { $headerRowCount += $subheader.Count }

    $combinedOptionsHeight = $combinedOptions.Count
    $totalMenuHeight = $combinedOptionsHeight + $headerRowCount

    if ($hasHeader) {
        Write-MenuHeader -Header $Header -HeaderWidth $HeaderWidth
    }

    if ($hasSubheader) {
        $Subheader | ForEach-Object { Write-Host $_ -ForegroundColor $MenuTextColor }
    }

    $currentIndex = 0
    $startingRow = [System.Console]::CursorTop

    [System.Console]::CursorVisible = $False

    while ($true) {
        for ($i = 0; $i -lt $combinedOptionsHeight; $i++) {
            $color = if ($i -eq $currentIndex) { $MenuTextColor } else { 'Gray' }
            Write-Host ">  $($combinedOptions[$i])" -ForegroundColor $color
        }

        $keyInfo = $null

        # ReadKey is nested in a loop to enable script termination through SIGINT, AKA CTRL+C.
        while ($true) {
            if ([Console]::KeyAvailable) {
                $keyInfo = [Console]::ReadKey($true)
                break
            }
        }

        switch ($keyInfo.Key) {
            { $_ -in "UpArrow", "K" } {
                $currentIndex = [Math]::Max(0, $currentIndex - 1)
                break
            }
            { $_ -in "DownArrow", "J" } {
                $currentIndex = [Math]::Min($combinedOptionsHeight - 1, $currentIndex + 1)
                break
            }
            { $_ -in "Enter", "L" } {
                Exit-Menu -TotalMenuHeight $totalMenuHeight -CleanUpAfter $CleanUpAfter 

                [System.Console]::CursorVisible = $true
                return $combinedOptions[$currentIndex]
            }
            { ($_ -in ("Escape", "Q", "H")) -and $ExitOption } {
                Exit-Menu -TotalMenuHeight $totalMenuHeight -CleanUpAfter $CleanUpAfter 

                [System.Console]::CursorVisible = $true
                return $ExitOption
            }
        }

        # This is to correct for when the terminal scrolls after rendering the menu.
        $startingRow = [System.Console]::CursorTop - $combinedOptionsHeight
        [System.Console]::SetCursorPosition(0, $startingRow)
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

    $startingRow = [System.Console]::CursorTop

    if ($Header) { Write-MenuHeader -Header $Header -HeaderWidth $HeaderWidth }
    if ($Subheader) { $Subheader | ForEach-Object { Write-Host $_ -ForegroundColor $MenutextColor } }

    $userInput = Read-Host $Instruction

    $currentRow = [System.Console]::CursorTop
    $totalMenuHeight = $currentRow - $startingRow

    Exit-Menu -TotalMenuHeight $TotalMenuHeight -CleanUpAfter $CleanUpAfter 

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuHeader