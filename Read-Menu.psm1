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

        [int]$MaxOptions = 16,

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
    $hasSubheaders = $Subheaders -and $Subheaders.Count -gt 0

    $headerRowCount = 0
    if ($hasHeader) { $headerRowCount++ }
    if ($hasSubheaders) { $headerRowCount += $Subheaders.Count }

    $combinedOptionsHeight = $combinedOptions.Count
    $maxVisibleOptions = [Math]::Min($combinedOptionsHeight, $MaxOptions)
    $totalMenuHeight = $headerRowCount + $maxVisibleOptions

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
    $displayIndex = $maxVisibleOptions -lt $combinedOptionsHeight
    $startingRow = [System.Console]::CursorTop

    if ($true -eq $displayIndex) { $totalMenuHeight++ }

    [System.Console]::CursorVisible = $False

    while ($true) {
        [System.Console]::SetCursorPosition(0, $startingRow)

        for ($i = 0; $i -lt $maxVisibleOptions; $i++) {
            $index = $optionsOffset + $i

            $option = $combinedOptions[$index]
            $optionText = $option.Name ?? $option
            $optionIcon = "$($option.Icon ?? $null)"

            $isCurrent = $($index -eq $currentIndex)
            $lineColor = $isCurrent ? $Color : 'Gray'
            $prefix = $isCurrent ? '> ' : '  '

            $line = ($prefix + $optionIcon + $optionText).PadRight($HeaderWidth)

            Write-Host $line -ForegroundColor $lineColor
        }

        if (
            ($maxVisibleOptions -lt $combinedOptionsHeight)
        ) {
            Write-Host "  -- $($currentIndex + 1) / $combinedOptionsHeight --".PadRight($HeaderWidth) -ForegroundColor DarkGray
        }



        $keyInfo = $null

        while ($true) {
            if ([Console]::KeyAvailable) {
                $keyInfo = [Console]::ReadKey($true)
                break
            }
        }

        switch ($keyInfo.Key) {
            { $_ -in "UpArrow", "K" } {
                if ($currentIndex -gt 0) {
                    $currentIndex--

                    $scrollTopIndex = $optionsOffset + 1
                    if ($currentIndex -lt $scrollTopIndex) {
                        $optionsOffset = [Math]::Max($currentIndex - 1, 0)
                    }
                }
            }
            { $_ -in "DownArrow", "J" } {
                if ($currentIndex -lt $combinedOptionsHeight - 1) {
                    $currentIndex++

                    $scrollBottomIndex = $optionsOffset + $maxVisibleOptions - 2
                    if ($currentIndex -ge $scrollBottomIndex) {
                        $optionsOffset = $currentIndex - ($maxVisibleOptions - 2)

                        $maxOffset = [Math]::Max($combinedOptionsHeight - $maxVisibleOptions, 0)
                        if ($optionsOffset -gt $maxOffset) { $optionsOffset = $maxOffset }
                        if ($optionsOffset -lt 0) { $optionsOffset = 0 }
                    }
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
        if ($displayIndex) { $startingRow-- }
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