function Read-KeyInput {
    param (
        [ConsoleKey]$Key,
        [object[]]$Options,
        [object]$ExitOption,
        [int]$CurrentIndex,
        [int]$Offset,
        [int]$ListHeight
    )

    $result = $null

    switch ($Key) {
        { $_ -in "UpArrow", "K" } {
            if ($CurrentIndex -gt 0) {
                $CurrentIndex--

                $scrollTopIndex = $Offset + 1
                if ($CurrentIndex -lt $scrollTopIndex) {
                    $Offset = [Math]::Max($CurrentIndex - 1, 0)
                }
            }
        }
        { $_ -in "DownArrow", "J" } {
            if ($CurrentIndex -lt $OptionsCount - 1) {
                $CurrentIndex++

                $scrollBottomIndex = $Offset + $ListHeight - 2
                if ($CurrentIndex -ge $scrollBottomIndex) {
                    $Offset = $CurrentIndex - ($ListHeight - 2)

                    $maxOffset = [Math]::Max($Options.Count - $ListHeight, 0)
                    if ($Offset -gt $maxOffset) { $Offset = $maxOffset }
                    if ($Offset -lt 0) { $Offset = 0 }
                }
            }
        }
        { $_ -in "Enter", "L" } {
            $result = $options[$CurrentIndex]
        }
        { ($_ -in ("Escape", "Q", "H")) -and $ExitOption } {
            $result = $ExitOption
        }
    }

    return $CurrentIndex, $Offset, $result
}