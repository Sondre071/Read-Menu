function Write-MenuHeader() {
    param (
        [Parameter(Mandatory)]
        [string]$Header,

        [System.Nullable[int]]$HeaderWidth = 40,

        [System.Nullable[char]]$HeaderSymbol = '=',

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
}

function Clear-Menu($TotalMenuHeight) {

    # Jump $TotalMenuHeight lines up and clear everything below.
    Write-Host "`e[$($TotalMenuHeight)A" -NoNewLine
    Write-Host "`e[0J" -NoNewLine
}

function Read-Menu {
    param (
        [Parameter(Mandatory)]
        [object[]]$Options,

        [object]$ExitOption,

        [System.Nullable[string]]$Header,

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
            Write-Host $_ -ForegroundColor $MenuTextColor
        }
    }

    $currentIndex = 0
    $startingRow = [System.Console]::CursorTop

    [System.Console]::CursorVisible = $False

    while ($true) {
        for ($i = 0; $i -lt $combinedOptionsHeight; $i++) {
            $option = $combinedOptions[$i]

            # Uses the option's name if there is any. Else uses the option itself.
            $optionText = ($null -ne $option.Name) ? $option.Name : $option 

            # Uses the icon if there is any.
            $optionIcon = ($null -ne $option.Icon) ? "$($option.Icon) " : '' 

            $color = if ($i -eq $currentIndex) { $MenuTextColor } else { 'Gray' }
            $prefix = $i -eq $currentIndex ? '> ' : '  '

            $line = $prefix + $optionIcon + $optionText

            Write-Host $line -ForegroundColor $color
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
                $currentIndex = [Math]::Min($combinedOptionsHeight - 1, $currentIndex + 1)
            }
            { $_ -in "Enter", "L" } {
                Clear-Menu -TotalMenuHeight $totalMenuHeight

                [System.Console]::CursorVisible = $true
                return $combinedOptions[$currentIndex]
            }
            { ($_ -in ("Escape", "Q", "H")) -and $ExitOption } {
                Clear-Menu -TotalMenuHeight $totalMenuHeight

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

        [char]$HeaderSymbol = '=',

        [int]$HeaderWidth = 40,

        [string[]]$Subheaders,

        [string]$Instruction = 'You',

        [string]$MenuTextColor = 'Yellow'
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
            Write-Host $_ -ForegroundColor $MenuTextColor
        }
    }

    $userInput = Read-Host $Instruction

    $currentRow = [System.Console]::CursorTop
    $totalMenuHeight = $currentRow - $startingRow

    Clear-Menu -TotalMenuHeight $TotalMenuHeight

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuHeader