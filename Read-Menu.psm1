. (Join-Path $PSScriptRoot 'Helpers' 'Get-Options.ps1')
. (Join-Path $PSScriptRoot 'Helpers' 'Write-Options.ps1')
. (Join-Path $PSScriptRoot 'Helpers' 'Read-KeyInput.ps1')
. (Join-Path $PSScriptRoot 'Helpers' 'Clear-Menu.ps1')

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

    if ($null -eq $maxLen) {
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

    $options, $optionsCount = Get-Options `
        -Options $Options `
        -ExitOption $ExitOption

    $maxVisibleOptions = [Math]::Min($optionsCount, $MaxOptions)

    # Used to calculate the total height of the menu.
    $cursorBeforePrinting = [System.Console]::CursorTop

    if ('' -ne $Header) {
        Write-MenuHeader `
            -Header $Header `
            -HeaderWidth $HeaderWidth `
            -HeaderSymbol $HeaderSymbol
    }

    if ($null -ne $Subheaders -and $Subheader.Count -gt 0) {
        $Subheaders | ForEach-Object {
            Write-Host $_ -ForegroundColor $Color
        }
    }

    $menuHeight = $maxVisibleOptions + (
        [System.Console]::CursorTop - $cursorBeforePrinting
    )

    $startingRow = [System.Console]::CursorTop
    $showIndex = $maxVisibleOptions -lt $optionsCount
    $currentIndex = 0
    $offset = 0

    if ($showIndex) { $menuHeight++ }

    [System.Console]::CursorVisible = $False

    while ($true) {
        [System.Console]::SetCursorPosition(0, $startingRow)

        Write-Options `
            -Options $options `
            -CurrentIndex $currentIndex `
            -Offset $offset `
            -ListHeight $maxVisibleOptions `
            -SelectedColor $Color `
            -DefaultColor 'Gray'

        $keyInfo = $null

        while ($true) {
            if ([Console]::KeyAvailable) {
                $keyInfo = [Console]::ReadKey($true)
                break
            }
        }

        $currentIndex, $offset, $result = Read-KeyInput `
            -Key $keyInfo.Key `
            -Options $options `
            -ExitOption $ExitOption `
            -CurrentIndex $currentIndex `
            -Offset $offset `
            -ListHeight $maxVisibleOptions
        
        if ($null -ne $result) {
            Clear-Menu -Height $menuHeight
            [System.Console]::CursorVisible = $true

            return $result
        }

        # This is to correct when the terminal scrolls after rendering the menu.
        $startingRow = [System.Console]::CursorTop - $maxVisibleOptions
        if ($showIndex) { $startingRow-- }
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
    $menuHeight = $currentRow - $startingRow

    Clear-Menu -Height $menuHeight

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuHeader