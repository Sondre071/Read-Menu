function Write-MenuHeader() {
    param (
        [Parameter(Mandatory)]
        [string]$Header,

        [System.Nullable[int]]$HeaderWidth = 40,

        [System.Nullable[char]]$HeaderSymbol = '=',

        [string[]]$Subheaders,

        [string]$Color = 'Yellow'
    )

    $maxLen = & {
        if ($null -eq $HeaderWidth) {
            return $null
        }
        elseif ($null -eq $HeaderSymbol) {
            return $HeaderWidth
        }
        else {
            return $HeaderWidth - 4
        }
    }

    if (
        ($null -eq $maxLen)
    ) {
        Write-Host $line -ForegroundColor $Color
        return
    }

    if ($Header.Length -gt $maxLen) {
        $Header = $Header.Substring(0, $maxLen - 2) + '..'
    }

    $line = & {
        if ($null -eq $HeaderSymbol) {
            return $Header
        }
        else {
            $inner = " $Header "
            $pad = $HeaderWidth - $inner.Length

            $left = [Math]::Floor($pad / 2)
            $right = $pad - $left

            return ("$HeaderSymbol" * $left) + $inner + ("$HeaderSymbol" * $right)
        }
    }

    Write-Host $line -ForegroundColor $Color

    if ($SubHeaders.Count -gt 0) {
        $Subheaders | ForEach-Object {
            Write-Host $_ -ForegroundColor $Color
        }

        Write-Host
    }

}

function Clear-Menu([int]$Height) {

    # Jump $Height lines up and clear everything below.
    Write-Host "`e[$($Height)A" -NoNewLine
    Write-Host "`e[0J" -NoNewLine
}

function Read-Menu {
    param (
        [Parameter(Mandatory)]
        [object[]]$Options,

        [object]$ExitOption,

        [int]$MaxOptions = 6,

        [string]$Header,

        [System.Nullable[char]]$HeaderSymbol = '=',

        [System.Nullable[int]]$HeaderWidth = 40,

        [string[]]$Subheaders,

        [string]$Color = 'Yellow'
    )

    $combinedOptions = @()

    if ($Options) { $CombinedOptions += $Options }
    if ($ExitOption) { $CombinedOptions += $ExitOption }

    $hasHeader = -not [string]::IsNullOrWhiteSpace($Header)
    $hasSubheaders = $Subheaders.Count -gt 0

    $headerRowCount = 0

    if ($hasHeader) { $headerRowCount++ }
    if ($hasSubheaders) { $headerRowCount += $Subheaders.Count }

    $combinedOptionsHeight = $combinedOptions.Count
    $totalMenuHeight = $combinedOptionsHeight + $headerRowCount

    if ($hasHeader) {
        Write-MenuHeader `
            -Header $Header `
            -HeaderWidth $HeaderWidth `
            -HeaderSymbol $HeaderSymbol
    }

    if ($hasSubheaders) {
        $Subheaders | ForEach-Object {
            Write-Host $_ -ForegroundColor $Color
        }
    }

    $currentIndex = 0
    $optionsOffset = 0
    $maxVisibleOptions = [Math]::Min($combinedOptionsHeight, $MaxOptions)
    $startingRow = [System.Console]::CursorTop

    [System.Console]::CursorVisible = $False

    while ($true) {
        for ($i = $optionsOffset; $i -lt ($maxVisibleOptions + $optionsOffset); $i++) {
            $option = $combinedOptions[$i]

            $optionText = $option.Name ?? $option
            $optionIcon = "$($option.Icon ?? $null)"

            $lineColor = ($i -eq $currentIndex) ? $Color : 'Gray'
            $prefix = ($i -eq $currentIndex) ? '> ' : '  '

            $line = $prefix + $optionIcon + $optionText
            $line = $line.PadRight($consoleWidth)

            Write-Host $line -ForegroundColor $lineColor

            Set-Content -Path "./menu-debug" -Value "currentIndex = $currentIndex, optionsOffset = $optionsOffset" -Force | Out-Null
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
            }
            { $_ -in "DownArrow", "J" } {
                if (($currentIndex -eq $maxVisibleOptions + $optionsOffset - 2) -and ($currentIndex -lt $combinedOptionsHeight - $maxVisibleOptions)) {
                    $optionsOffset++
                }

                if ($currentIndex -lt $combinedOptionsHeight - $maxVisibleOptions) {
                    $currentIndex = [Math]::Min($combinedOptionsHeight - 1, $currentIndex + 1)
                }

            }
            { $_ -in "Enter", "L" } {
                Clear-Menu -Height $totalMenuHeight

                [System.Console]::CursorVisible = $true
                return $combinedOptions[$currentIndex]
            }
            { ($_ -in ("Escape", "Q", "H")) -and $ExitOption } {
                Clear-Menu -Height $totalMenuHeight

                [System.Console]::CursorVisible = $true
                return $ExitOption
            }
        }

        # This is to correct for when the terminal scrolls after rendering the menu.
        $startingRow = [System.Console]::CursorTop - $maxVisibleOptions
        [System.Console]::SetCursorPosition(0, $startingRow)
    }
}

function Read-Input() {
    param (
        [string]$Header,

        [char]$HeaderSymbol = '=',

        [int]$HeaderWidth = 40,

        [string[]]$Subheaders,

        [string]$Instruction = 'You',

        [string]$Color = 'Yellow'
    )

    $startingRow = [System.Console]::CursorTop

    if ($Header) {
        Write-MenuHeader `
            -Header $Header `
            -HeaderSymbol $HeaderSymbol `
            -HeaderWidth $HeaderWidth
    }
    if ($Subheaders -gt 0) {
        $Subheaders | ForEach-Object {
            Write-Host $_ -ForegroundColor $Color
        }
    }

    $userInput = Read-Host $Instruction

    $currentRow = [System.Console]::CursorTop
    $totalMenuHeight = $currentRow - $startingRow

    Clear-Menu -Height $TotalMenuHeight

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuHeader