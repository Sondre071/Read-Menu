. (Join-Path $PSScriptRoot 'Helpers' 'Clear-Menu.ps1')
. (Join-Path $PSScriptRoot 'Helpers' 'Get-Options.ps1')
. (Join-Path $PSScriptRoot 'Helpers' 'Read-KeyInput.ps1')
. (Join-Path $PSScriptRoot 'Helpers' 'Write-Options.ps1')

function Write-MenuHeader()
{
    param (
        [Parameter(Mandatory)]
        [string]$Header,
        [string[]]$Subheaders,

        [string]$Color = 'Yellow',
        [System.Nullable[int]]$HeaderWidth = 40,
        [System.Nullable[char]]$HeaderSymbol = '━'
    )

    $lineLen = & {
        if ($null -eq $HeaderWidth)
        {
            return (Get-Host).UI.RawUI.WindowSize.Width - 2
        } elseif ($null -eq $HeaderSymbol)
        {
            return $HeaderWidth
        } else
        {
            # Four to allow space for the symbol, two for padding around the text.
            return $HeaderWidth - 6
        }
    }

    if ($Header.Length -gt $lineLen)
    {
        $Header = $Header.Substring(0, $lineLen - 2) + '..'
    }

    $line = & {
        if ($null -eq $HeaderSymbol)
        {
            return $Header
        } else
        {
            $padLeft = "$HeaderSymbol" * [Math]::Floor(($lineLen - $Header.Length) / 2)
            $padRight = "$HeaderSymbol" * ($lineLen - $Header.Length - $padLeft.Length)

            return "{0} {1} {2}" -f $padLeft, $Header, $padRight
        }
    }

    Write-Host $line -ForegroundColor $Color

    foreach ($subheader in $Subheaders)
    {
        Write-Host $subheader -ForegroundColor $Color
    }

}

function Read-Menu
{
    param (
        [string]$Header,
        [Parameter(Mandatory)]
        [object[]]$Options,
        [string[]]$Subheaders,
        [object]$ExitOption,

        [string]$Color = 'Yellow',
        [System.Nullable[char]]$HeaderSymbol = '━',
        [System.Nullable[int]]$HeaderWidth = 40,
        [int]$MaxOptions = 16
    )

    $options = Get-Options `
        -Options $Options `
        -ExitOption $ExitOption

    $maxVisibleOptions = [Math]::Min($options.Count, $MaxOptions)
    $showIndex = $maxVisibleOptions -lt $options.Count

    $headerLines = 0
    if ('' -ne $Header)
    {
        $headerLines++
    }
    $headerLines += $Subheaders.Count

    $menuHeight = $headerLines + $maxVisibleOptions
    if ($showIndex)
    {
        $menuHeight++
    }

    # Reserve the full area instead of scrolling during render.
    Write-Host ("`n" * $menuHeight) -NoNewline
    Write-Host "`e[$($menuHeight)A" -NoNewline

    $startRow = [System.Console]::CursorTop

    if ('' -ne $Header)
    {
        Write-MenuHeader `
            -Header $Header `
            -HeaderWidth $HeaderWidth `
            -HeaderSymbol $HeaderSymbol
    }

    foreach ($subheader in $Subheaders)
    {
        Write-Host $subheader -ForegroundColor $Color
    }

    $optionsRow = $startRow + $headerLines
    $currentIndex = 0
    $offset = 0

    [System.Console]::CursorVisible = $false

    try
    {
        while ($true)
        {
            [System.Console]::SetCursorPosition(0, $optionsRow)

            Write-Options `
                -Options $options `
                -CurrentIndex $currentIndex `
                -Offset $offset `
                -ListHeight $maxVisibleOptions `
                -SelectedColor $Color `
                -DefaultColor 'Gray'

            while (-not [Console]::KeyAvailable)
            {
                Start-Sleep -Milliseconds 10
            }

            $keyInfo = [Console]::ReadKey($true)

            $currentIndex, $offset, $result = Read-KeyInput `
                -Key $keyInfo.Key `
                -Options $options `
                -ExitOption $ExitOption `
                -CurrentIndex $currentIndex `
                -Offset $offset `
                -ListHeight $maxVisibleOptions

            if ($null -ne $result)
            {
                Clear-Menu -Height $menuHeight

                return $result
            }
        }
    } finally
    {
        [System.Console]::CursorVisible = $true
    }
}

function Read-Input()
{
    param (
        [string]$Header,
        [string[]]$Subheaders,
        [string]$Instruction = 'You',

        [string]$Color = 'Yellow',
        [System.Nullable[char]]$HeaderSymbol = '─',
        [System.Nullable[int]]$HeaderWidth = 40
    )

    $startRow = [System.Console]::CursorTop

    if ($Header)
    {
        Write-MenuHeader `
            -Header $Header `
            -HeaderSymbol $HeaderSymbol `
            -HeaderWidth $HeaderWidth
    }

    foreach ($subheader in $Subheaders)
    {
        Write-Host $subheader -ForegroundColor $Color
    }

    $userInput = Read-Host $Instruction

    $currentRow = [System.Console]::CursorTop
    $menuHeight = $currentRow - $startRow

    Clear-Menu -Height $menuHeight

    return $userInput
}

Export-ModuleMember -Function Read-Menu
Export-ModuleMember -Function Read-Input
Export-ModuleMember -Function Write-MenuHeader
