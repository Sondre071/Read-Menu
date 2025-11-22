function Write-Options {
    [OutputType([void])]
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
        $optionIcon = $option.Icon ?? ''

        $isSelected = $index -eq $CurrentIndex
        $lineColor = $isSelected ? $SelectedColor : $DefaultColor
        $prefix = $isSelected ? '>' : ' '

        $line = ("{0} {1}{2}" -f $prefix, $optionIcon, $optionText).PadRight($consoleWidth)

        Write-Host $line -ForegroundColor $lineColor
    }

    if (
        ($ListHeight -lt $Options.Count)
    ) {
        $line = ("  -- {0} / {1} --" -f ($CurrentIndex + 1), $Options.Count).PadRight($consoleWidth)

        Write-Host $line -ForegroundColor 'DarkGray'
    }
}