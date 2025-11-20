function Write-Options {
    param (
        [object[]]$Options,
        [int]$CurrentIndex,
        [int]$Offset,
        [int]$ListHeight,
        [ConsoleColor]$SelectedColor,
        [ConsoleColor]$DefaultColor
    )

    $consoleWidth = (Get-Host).UI.RawUI.WindowSize.Width 

    for ($i = 0; $i -lt $ListHeight; $i++) {
        $index = $Offset + $i

        $option = $Options[$index]
        $optionText = $option.Name ?? $option
        $optionIcon = "$($option.Icon ?? $null)"

        $isSelected = $($index -eq $CurrentIndex)
        $lineColor = $isSelected ? $SelectedColor : $DefaultColor
        $prefix = $isSelected ? '> ' : '  '

        $line = ($prefix + $optionIcon + $optionText).PadRight($consoleWidth)

        Write-Host $line -ForegroundColor $lineColor
    }

    if (
        ($ListHeight -lt $Options.Count)
    ) {
        Write-Host "  -- $($CurrentIndex + 1) / $($Options.Count) --".PadRight($consoleWidth) -ForegroundColor DarkGray
    }

}